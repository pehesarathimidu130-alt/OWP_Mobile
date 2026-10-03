import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'app_config.dart';

import 'package:image_picker/image_picker.dart';

export 'api_service.dart' show ApiException;

/// Shared API client for backward compatibility across the app.
/// Delegates core calls to the centralized [ApiService].
class ApiClient {
  static String get baseUrl => AppConfig.baseUrl;

  final ApiService _service;

  ApiClient({http.Client? httpClient, FlutterSecureStorage? storage})
      : _service = ApiService(httpClient: httpClient, storage: storage);

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) =>
      _service.get(endpoint, queryParams: queryParams);

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) =>
      _service.post(endpoint, body: body);

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) =>
      _service.put(endpoint, body: body);

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) =>
      _service.patch(endpoint, body: body);

  Future<dynamic> delete(String endpoint) => _service.delete(endpoint);

  Future<dynamic> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    XFile? file,
    String fileFieldName = 'file',
  }) =>
      _service.postMultipart(
        endpoint,
        fields: fields,
        file: file,
        fileFieldName: fileFieldName,
      );
}
