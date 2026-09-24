import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import '../models/listing_model.dart';
import '../models/vendor_model.dart';

/// Exception thrown on network failure, non-2xx status, or bad JSON.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  /// Extracts the most descriptive human-readable message from .NET RFC 7807 ProblemDetails
  /// or validation dictionaries.
  factory ApiException.fromResponse(int statusCode, dynamic body) {
    String extractedMessage = 'Request failed with status: $statusCode';

    if (body is Map<String, dynamic>) {
      // 1. RFC 7807 ProblemDetails 'detail' (e.g. 409 Conflict: "A user with this email already exists.")
      if (body['detail'] != null && body['detail'].toString().trim().isNotEmpty) {
        extractedMessage = body['detail'].toString().trim();
      }
      // 2. ASP.NET Core ModelState / ValidationProblemDetails 'errors'
      else if (body['errors'] is Map) {
        final errorMap = body['errors'] as Map;
        final List<String> messages = [];
        for (final entry in errorMap.entries) {
          if (entry.value is List) {
            for (final err in (entry.value as List)) {
              if (err != null && err.toString().trim().isNotEmpty) {
                messages.add(err.toString().trim());
              }
            }
          } else if (entry.value != null) {
            messages.add(entry.value.toString().trim());
          }
        }
        if (messages.isNotEmpty) {
          extractedMessage = messages.join('\n');
        } else if (body['title'] != null) {
          extractedMessage = body['title'].toString();
        }
      }
      // 3. Custom 'message' field
      else if (body['message'] != null && body['message'].toString().trim().isNotEmpty) {
        extractedMessage = body['message'].toString().trim();
      }
      // 4. 'title' field
      else if (body['title'] != null && body['title'].toString().trim().isNotEmpty) {
        extractedMessage = body['title'].toString().trim();
      }
    } else if (body is String && body.trim().isNotEmpty) {
      extractedMessage = body.trim();
    }

    return ApiException(extractedMessage, statusCode: statusCode, details: body);
  }

  @override
  String toString() => message;
}

/// Centralized API service for communicating with the .NET Core backend.
///
/// Base URL defaults to [AppConfig.baseUrl] (http://localhost:5131/api on Web).
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService({http.Client? httpClient, FlutterSecureStorage? storage}) {
    if (httpClient != null || storage != null) {
      return ApiService._internal(httpClient: httpClient, storage: storage);
    }
    return _instance;
  }

  ApiService._internal({http.Client? httpClient, FlutterSecureStorage? storage})
      : _httpClient = httpClient ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  final http.Client _httpClient;
  final FlutterSecureStorage _storage;

  /// Runtime base URL (Chrome Web: http://localhost:5131/api)
  String get baseUrl => AppConfig.baseUrl;

  /// Default headers including JSON Content-Type and Bearer auth token if present
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      final token = await _storage.read(key: AppConfig.kAuthToken);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Storage access may fail in non-browser environments or unsupported modes
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final sanitizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final sanitizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$sanitizedBase$sanitizedEndpoint';

    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      )..removeWhere((key, value) => value.isEmpty);
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  /// Sends a GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);
    final headers = await _getHeaders();

    try {
      final response = await _httpClient.get(uri, headers: headers);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException('Network unreachable: Please ensure backend is running at $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: Cannot reach backend at $baseUrl (${e.message})');
    }
  }

  /// Sends a POST request with jsonEncode-ed body
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final uri = _buildUri(endpoint);
    final headers = await _getHeaders();

    try {
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException('Network unreachable: Please ensure backend is running at $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: Cannot reach backend at $baseUrl (${e.message})');
    }
  }

  /// Sends a PUT request
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    final uri = _buildUri(endpoint);
    final headers = await _getHeaders();

    try {
      final response = await _httpClient.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException('Network unreachable: Please ensure backend is running at $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: Cannot reach backend at $baseUrl (${e.message})');
    }
  }

  /// Sends a DELETE request
  Future<dynamic> delete(String endpoint) async {
    final uri = _buildUri(endpoint);
    final headers = await _getHeaders();

    try {
      final response = await _httpClient.delete(uri, headers: headers);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException('Network unreachable: Please ensure backend is running at $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: Cannot reach backend at $baseUrl (${e.message})');
    }
  }

  // ─── Domain-specific helpers ───────────────────────────────────────────────

  /// Fetches business services / packages from GET /api/listings
  Future<List<Listing>> fetchListings({String? category, String? search}) async {
    final query = <String, dynamic>{};
    if (category != null && category != 'All') query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;

    try {
      final data = await get('/listings', queryParams: query);
      if (data is List) {
        return data
            .map((item) => Listing.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on ApiException catch (e) {
      // Fallback to /vendors or /public/landing/featured-listings if /listings is unavailable
      if (e.statusCode == 404) {
        final fallbackData = await get('/vendors', queryParams: query);
        if (fallbackData is List) {
          return fallbackData
              .map((item) => Listing.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      rethrow;
    }
    return [];
  }

  /// Fetches a specific listing by ID from GET /api/listings/{id}
  Future<Listing> fetchListingById(int id) async {
    final data = await get('/listings/$id');
    return Listing.fromJson(data as Map<String, dynamic>);
  }

  /// Toggles favorite status for a listing (adds if absent, removes if present).
  /// Sends POST /api/favorites/toggle/{listingId} with Bearer token.
  Future<bool> toggleFavorite(int listingId) async {
    try {
      final response = await post('/favorites/toggle/$listingId');
      if (response is Map<String, dynamic> && response.containsKey('isFavorite')) {
        return response['isFavorite'] == true;
      }
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        final fallback = await post('/favorites/$listingId');
        if (fallback is Map<String, dynamic> && fallback.containsKey('isFavorite')) {
          return fallback['isFavorite'] == true;
        }
      }
      rethrow;
    }
  }

  /// Explicitly removes a listing from favorites via DELETE /api/favorites/{listingId}.
  Future<bool> removeFavorite(int listingId) async {
    final uri = _buildUri('/favorites/$listingId');
    final headers = await _getHeaders();
    final response = await _httpClient.delete(uri, headers: headers);
    final processed = _processResponse(response);
    if (processed is Map<String, dynamic> && processed.containsKey('isFavorite')) {
      return processed['isFavorite'] == true;
    }
    return false;
  }

  /// Fetches all favorited listings for the authenticated user from GET /api/favorites.
  Future<List<Listing>> getFavoriteListings() async {
    final data = await get('/favorites');
    if (data is List) {
      return data
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches the IDs of all favorited listings for the authenticated user.
  Future<List<int>> getFavoriteIds() async {
    try {
      final data = await get('/favorites/ids');
      if (data is List) {
        return data
            .map((item) => item is int ? item : int.tryParse(item.toString()) ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetches vendor list from GET /api/vendors
  Future<List<Vendor>> fetchVendors({String? category, String? search}) async {
    final query = <String, dynamic>{};
    if (category != null && category != 'All') query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final data = await get('/vendors', queryParams: query);
    if (data is List) {
      return data
          .map((item) => Vendor.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Registers a new user via POST /api/auth/register (or /api/auth/customer/register)
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'fullName': fullName.trim(),
      'name': fullName.trim(), // Alias for .NET CustomerRegisterRequestDto
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'phone': phoneNumber.trim(), // Alias for .NET CustomerRegisterRequestDto
      'password': password,
    };

    try {
      final response = await post('/auth/register', body: payload);
      return (response as Map<String, dynamic>?) ?? {};
    } on ApiException catch (e) {
      // If /auth/register returns 404, fallback to /auth/customer/register
      if (e.statusCode == 404) {
        final response = await post('/auth/customer/register', body: payload);
        return (response as Map<String, dynamic>?) ?? {};
      }
      rethrow;
    }
  }

  // ─── Internal Response Processing ──────────────────────────────────────────

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic decodedBody;
    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    throw ApiException.fromResponse(statusCode, decodedBody);
  }
}
