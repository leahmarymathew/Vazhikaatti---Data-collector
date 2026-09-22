import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}$path'))
          .timeout(ApiConfig.requestTimeout);
      return _decode(response);
    } catch (error) {
      throw ApiException(_message(error));
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);
      return _decode(response);
    } catch (error) {
      throw ApiException(_message(error));
    }
  }

  Future<Map<String, dynamic>> upload(
    String path,
    String imagePath,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}$path'))
            ..files.add(await http.MultipartFile.fromPath('image', imagePath))
            ..fields['metadata'] = jsonEncode(metadata);
      final response = await http.Response.fromStream(
        await request.send().timeout(ApiConfig.requestTimeout),
      );
      return _decode(response);
    } catch (error) {
      throw ApiException(_message(error));
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map ? decoded['detail'] : null;
      throw ApiException(
        detail?.toString() ?? 'Server returned HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Server returned an invalid response');
    }
    return decoded;
  }

  String _message(Object error) => error is ApiException
      ? error.message
      : 'Server is temporarily unavailable';
}
