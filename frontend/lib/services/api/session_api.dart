import '../api/api_client.dart';
import '../../data/models/legacy_models.dart';

class SessionApi {
  SessionApi(this.client);
  final ApiClient client;
  Future<void> create(CaptureSession session) async =>
      client.postJson('/api/v1/sessions', session.toMap());
}
