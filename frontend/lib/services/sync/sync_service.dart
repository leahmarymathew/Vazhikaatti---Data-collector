import '../../data/database/local_database.dart';
import '../../data/models/capture_metadata.dart';
import '../../data/models/legacy_models.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';

class SyncService {
  SyncService({LocalDatabase? database, ApiClient? client})
    : _database = database ?? LocalDatabase.instance,
      _client = client ?? ApiClient();
  final LocalDatabase _database;
  final ApiClient _client;

  Future<SyncReport> syncPending() async {
    final candidates = await _database.syncCandidates();
    var uploaded = 0;
    var failed = 0;
    for (final capture in candidates) {
      try {
        await _upload(capture);
        uploaded++;
      } catch (error) {
        failed++;
        await _database.updateCaptureSync(
          capture.copyWith(
            syncState: 'failed',
            syncAttemptCount: capture.syncAttemptCount + 1,
            lastSyncAttempt: DateTime.now(),
            lastSyncError: _friendly(error),
          ),
        );
      }
    }
    final counts = await _database.syncCounts();
    return SyncReport(
      uploaded: uploaded,
      failed: failed,
      pending: counts['pending'] ?? 0,
      uploadedTotal: counts['uploaded'] ?? 0,
    );
  }

  Future<void> _upload(CaptureRecord capture) async {
    final now = DateTime.now();
    await _database.updateCaptureSync(
      capture.copyWith(
        syncState: 'uploading',
        syncAttemptCount: capture.syncAttemptCount + 1,
        lastSyncAttempt: now,
        lastSyncError: null,
      ),
    );
    final metadata = CaptureMetadata.fromJson({
      ...capture.metadata,
      'image_id': capture.id,
      'filename': capture.filename,
      'capture_session_id': capture.sessionId,
      'checksum': capture.metadata['checksum'],
    }).toJson();
    final result = await _client.upload(
      '/api/v1/captures/upload',
      capture.imagePath,
      metadata,
    );
    await _database.updateCaptureSync(
      capture.copyWith(
        syncState: 'uploaded',
        serverImageId: result['image_id'] as String?,
        uploadedAt: DateTime.now(),
        lastSyncAttempt: now,
        lastSyncError: null,
      ),
    );
  }

  Future<bool> isOnline() async {
    try {
      await _client.getJson('/health');
      return true;
    } catch (_) {
      return false;
    }
  }

  String _friendly(Object error) => error is ApiException
      ? error.message
      : 'Server is temporarily unavailable. Capture remains safely stored on this phone.';
}

class SyncReport {
  const SyncReport({
    required this.uploaded,
    required this.failed,
    required this.pending,
    required this.uploadedTotal,
  });
  final int uploaded;
  final int failed;
  final int pending;
  final int uploadedTotal;
}
