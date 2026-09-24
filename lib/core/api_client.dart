import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'app_config.dart';

export 'api_service.dart' show ApiException;

/// Shared API client for backward compatibility across the app.
/// Delegates core calls to the centralized [ApiService].
class ApiClient {
  static String get baseUrl => AppConfig.baseUrl;

  final ApiService _service;

  ApiClient({http.Client? httpClient, FlutterSecureStorage? storage})
      : _service = ApiService(httpClient: httpClient, storage: storage);

  Future<dynamic> get(String endpoint) => _service.get(endpoint);

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) =>
      _service.post(endpoint, body: body);

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) =>
      _service.put(endpoint, body: body);

  Future<dynamic> delete(String endpoint) => _service.delete(endpoint);
}
