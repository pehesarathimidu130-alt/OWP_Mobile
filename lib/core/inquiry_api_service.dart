import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/inquiry_model.dart';
import 'api_service.dart';

/// Dedicated API service for Customer Inquiries delegating to shared [ApiService].
///
/// Ensures all inquiry network calls go through the centralized [ApiService]
/// for consistent token management, global 401 expiration handling, and base URL resolution.
class InquiryApiService {
  final ApiService _apiService;

  InquiryApiService({
    ApiService? apiService,
    http.Client? httpClient,
    FlutterSecureStorage? storage,
  }) : _apiService = apiService ?? ApiService(httpClient: httpClient, storage: storage);

  /// Runtime base URL from shared [ApiService]
  String get baseUrl => _apiService.baseUrl;

  /// Fetches the logged-in customer's inquiries directly from `GET /api/inquiries`.
  Future<List<Inquiry>> getMyInquiries() => _apiService.getMyInquiries();

  /// Submits an inquiry to a vendor with multipart form data (supports optional photo)
  Future<Map<String, dynamic>> submitInquiry({
    required int vendorId,
    int? serviceId,
    DateTime? weddingDate,
    int? guestCount,
    double? budget,
    required String message,
    XFile? photoAttachment,
  }) {
    return _apiService.submitInquiry(
      vendorId: vendorId,
      serviceId: serviceId,
      weddingDate: weddingDate,
      guestCount: guestCount,
      budget: budget,
      message: message,
      photoAttachment: photoAttachment,
    );
  }

  /// Updates an existing pending inquiry via `PUT /api/inquiries/{id}`
  Future<void> updateInquiry({
    required int inquiryId,
    DateTime? weddingDate,
    int? guestCount,
    double? budget,
    String? message,
  }) {
    return _apiService.updateInquiry(
      inquiryId: inquiryId,
      weddingDate: weddingDate,
      guestCount: guestCount,
      budget: budget,
      message: message,
    );
  }

  /// Deletes an inquiry via `DELETE /api/inquiries/{id}`
  Future<void> deleteInquiry(int inquiryId) {
    return _apiService.deleteInquiry(inquiryId);
  }
}
