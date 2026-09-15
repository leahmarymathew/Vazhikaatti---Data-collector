import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database.dart';
import '../data/models.dart';

class StorageService {
  Future<Directory> root() async => Directory(
    p.join(
      (await getApplicationDocumentsDirectory()).path,
      'VazhikattiDataset',
    ),
  )..createSync(recursive: true);
  Future<String> saveImage(
    File source,
    String sessionId,
    String imageId,
  ) async {
    final dir = Directory(p.join((await root()).path, 'images', sessionId))
      ..createSync(recursive: true);
    final bytes = await source.readAsBytes();
    final checksum = sha256.convert(bytes).toString();
    final destination = File(p.join(dir.path, '$imageId.jpg'));
    await destination.writeAsBytes(bytes, flush: true);
    return '${destination.path}|$checksum';
  }

  Future<File> exportDataset() async {
    final base = await root();
    final captures = await LocalDatabase.instance.captures();
    final sessions = await LocalDatabase.instance.sessions();
    final archive = Archive();
    final metadata = captures
        .map(
          (c) => {
            ...c.metadata,
            'image_id': c.id,
            'filename': c.filename,
            'session_id': c.sessionId,
          },
        )
        .toList();
    archive.addFile(
      ArchiveFile(
        'metadata.json',
        utf8.encode(jsonEncode(metadata)).length,
        utf8.encode(jsonEncode(metadata)),
      ),
    );
    archive.addFile(
      ArchiveFile(
        'sessions.json',
        utf8.encode(jsonEncode(sessions.map((s) => s.toMap()).toList())).length,
        utf8.encode(jsonEncode(sessions.map((s) => s.toMap()).toList())),
      ),
    );
    final rows = <List<dynamic>>[
      metadata.isEmpty ? ['image_id'] : metadata.first.keys.toList(),
      ...metadata.map(
        (m) => (metadata.first.keys.map((key) => m[key]).toList()),
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    archive.addFile(
      ArchiveFile('metadata.csv', utf8.encode(csv).length, utf8.encode(csv)),
    );
    archive.addFile(
      ArchiveFile(
        'nodes.json',
        utf8.encode(jsonEncode(sampleNodes)).length,
        utf8.encode(jsonEncode(sampleNodes)),
      ),
    );
    archive.addFile(
      ArchiveFile(
        'README.txt',
        206,
        utf8.encode(
          'Vazhikatti Dataset Export\nGenerated fully offline. GPS is rough positioning only; floor and node are explicit ground truth.\n',
        ),
      ),
    );
    for (final capture in captures) {
      final file = File(capture.imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        archive.addFile(
          ArchiveFile('images/${capture.filename}', bytes.length, bytes),
        );
      }
    }
    final exportDir = Directory(p.join(base.path, 'exports'))
      ..createSync(recursive: true);
    final out = File(
      p.join(
        exportDir.path,
        'vazhikatti_${DateTime.now().millisecondsSinceEpoch}.zip',
      ),
    );
    final bytes = ZipEncoder().encode(archive);
    await out.writeAsBytes(bytes!);
    return out;
  }

  Future<void> shareExport(File file) => Share.shareXFiles([
    XFile(file.path),
  ], subject: 'Vazhikatti offline dataset');
}
