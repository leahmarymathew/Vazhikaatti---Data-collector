import 'api_client.dart';

class CaptureApi {
  CaptureApi(this.client);
  final ApiClient client;
  Future<Map<String, dynamic>> upload(
    Map<String, dynamic> metadata,
    String imagePath,
  ) => client.upload('/api/v1/captures/upload', imagePath, metadata);
  Future<Map<String, dynamic>> health() => client.getJson('/health');
}
