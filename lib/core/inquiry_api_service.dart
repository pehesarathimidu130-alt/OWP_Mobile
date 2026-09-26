import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'app_config.dart';
import '../models/inquiry_model.dart';
import 'api_service.dart';

/// Dedicated API service for Customer Inquiries.
///
/// ════════════════════════════════════════════════════════════════════════════
/// ⚠️ BACKEND ROUTING VERIFICATION (.NET CONTROLLER):
/// ════════════════════════════════════════════════════════════════════════════
/// Controller: `OWP_Backend/Controllers/InquiriesController.cs`
/// Attribute:   `[Route("api/[controller]")]` -> Base route: `/api/inquiries`
///
/// Endpoints:
///   • GET  /api/inquiries/customer (or GET /api/inquiries) -> Fetch logged-in user inquiries
///   • POST /api/inquiries                                 -> Submit new inquiry (multipart)
///   • PUT  /api/inquiries/{id}                            -> Update pending inquiry
///   • DELETE /api/inquiries/{id}                          -> Delete inquiry
///
/// NOTE: If receiving a 404 error, ensure the .NET backend has been restarted
/// (`dotnet run` or `dotnet watch run`) so the InquiriesController assembly is loaded.
/// ════════════════════════════════════════════════════════════════════════════
class InquiryApiService {
  final http.Client _httpClient;
  final FlutterSecureStorage _storage;

  InquiryApiService({http.Client? httpClient, FlutterSecureStorage? storage})
      : _httpClient = httpClient ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  String get baseUrl => AppConfig.baseUrl;

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: AppConfig.kAuthToken);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetches the logged-in customer's inquiries.
  ///
  /// Target .NET URL: `GET http://{host}:5131/api/inquiries/customer`
  /// (Falls back to `GET /api/inquiries` if `/customer` route is not defined)
  Future<List<Inquiry>> getMyInquiries() async {
    final headers = await _getHeaders();

    // 1. Try standard route: /api/inquiries/customer
    final primaryUri = Uri.parse('$baseUrl/inquiries/customer');
    try {
      final response = await _httpClient.get(primaryUri, headers: headers);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => Inquiry.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else if (response.statusCode != 404) {
        throw ApiException.fromResponse(response.statusCode, response.body);
      }
    } on SocketException catch (e) {
      throw ApiException('Network unreachable at $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: Cannot reach backend at $baseUrl (${e.message})');
    }

    // 2. Fallback to /api/inquiries
    final fallbackUri = Uri.parse('$baseUrl/inquiries');
    try {
      final response = await _httpClient.get(fallbackUri, headers: headers);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => Inquiry.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw ApiException.fromResponse(response.statusCode, response.body);
    } on SocketException catch (e) {
      throw ApiException('Network unreachable at $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: Cannot reach backend at $baseUrl (${e.message})');
    }
  }

  /// Submits an inquiry to a vendor with multipart form data (supports optional photo)
  Future<Map<String, dynamic>> submitInquiry({
    required int vendorId,
    int? serviceId,
    required DateTime? weddingDate,
    int? guestCount,
    double? budget,
    required String message,
    XFile? photoAttachment,
  }) async {
    final uri = Uri.parse('$baseUrl/inquiries');
    final request = http.MultipartRequest('POST', uri);

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['vendorId'] = vendorId.toString();
    if (serviceId != null && serviceId > 0) {
      request.fields['serviceId'] = serviceId.toString();
    }
    if (weddingDate != null) {
      request.fields['weddingDate'] = weddingDate.toIso8601String();
    }
    if (guestCount != null && guestCount > 0) {
      request.fields['guestCount'] = guestCount.toString();
    }
    if (budget != null && budget > 0) {
      request.fields['budget'] = budget.toString();
    }
    request.fields['message'] = message;

    if (photoAttachment != null) {
      final bytes = await photoAttachment.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: photoAttachment.name.isNotEmpty
              ? photoAttachment.name
              : 'inquiry_attachment.jpg',
        ),
      );
    }

    try {
      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          try {
            return jsonDecode(response.body) as Map<String, dynamic>;
          } catch (_) {
            return {'success': true};
          }
        }
        return {'success': true};
      }
      throw ApiException.fromResponse(response.statusCode, response.body);
    } on SocketException catch (e) {
      throw ApiException('Network unreachable at $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: Cannot reach backend at $baseUrl (${e.message})');
    }
  }

  /// Updates an existing pending inquiry
  Future<void> updateInquiry({
    required int inquiryId,
    DateTime? weddingDate,
    int? guestCount,
    double? budget,
    String? message,
  }) async {
    final uri = Uri.parse('$baseUrl/inquiries/$inquiryId');
    final headers = await _getHeaders();
    final payload = <String, dynamic>{};
    if (weddingDate != null) {
      payload['weddingDate'] = weddingDate.toIso8601String();
    }
    if (guestCount != null) {
      payload['guestCount'] = guestCount;
    }
    if (budget != null) {
      payload['budget'] = budget;
    }
    if (message != null) {
      payload['message'] = message;
    }

    final response = await _httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  /// Deletes an inquiry
  Future<void> deleteInquiry(int inquiryId) async {
    final uri = Uri.parse('$baseUrl/inquiries/$inquiryId');
    final headers = await _getHeaders();
    final response = await _httpClient.delete(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }
}
