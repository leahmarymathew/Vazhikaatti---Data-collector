import 'api_client.dart';

class NodeApi {
  NodeApi(this.client);
  final ApiClient client;
  Future<void> create(Map<String, dynamic> node) async =>
      client.postJson('/api/v1/nodes', node);
}
