import 'package:flutter/foundation.dart';
import '../../../core/api_client.dart';
import '../../../core/auth_provider.dart';
import '../../../models/customer_profile_model.dart';

/// Provider managing customer profile state, remote fetching, updates, and password changes.
class CustomerProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  CustomerProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  CustomerProfileProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  CustomerProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches the authenticated customer's profile from OWP Backend.
  Future<void> fetchProfile({AuthProvider? authFallback}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/customer/profile');

      if (response != null && response is Map<String, dynamic>) {
        _profile = CustomerProfile.fromJson(response);
      }
    } on ApiException catch (e) {
      // Graceful fallback to AuthProvider cached session data if offline or dev
      if (authFallback != null && authFallback.isAuthenticated) {
        final fullName = authFallback.displayName;
        final parts = fullName.split(' ');
        final firstName = parts.isNotEmpty ? parts.first : 'Customer';
        final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';

        _profile = CustomerProfile(
          customerId: authFallback.customerId ?? 1,
          userId: 1,
          firstName: firstName,
          lastName: lastName,
          fullName: fullName,
          email: authFallback.email ?? '',
          phoneNumber: null,
          createdAt: DateTime.now(),
        );
      } else {
        _errorMessage = e.message;
      }
    } catch (_) {
      if (authFallback != null && authFallback.isAuthenticated) {
        final fullName = authFallback.displayName;
        final parts = fullName.split(' ');
        final firstName = parts.isNotEmpty ? parts.first : 'Customer';
        final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';

        _profile = CustomerProfile(
          customerId: authFallback.customerId ?? 1,
          userId: 1,
          firstName: firstName,
          lastName: lastName,
          fullName: fullName,
          email: authFallback.email ?? '',
          phoneNumber: null,
          createdAt: DateTime.now(),
        );
      } else {
        _errorMessage = 'Could not load profile. Please check your connection.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates personal details: First Name, Last Name, Phone Number.
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final body = {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phoneNumber': phoneNumber?.trim(),
    };

    try {
      final response = await _apiClient.put('/customer/profile', body: body);

      if (response != null && response is Map<String, dynamic>) {
        _profile = CustomerProfile.fromJson(response);
      } else if (_profile != null) {
        _profile = _profile!.copyWith(
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          fullName: '$firstName $lastName'.trim(),
          phoneNumber: phoneNumber?.trim(),
        );
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404 && _profile != null) {
        // Local simulation fallback
        _profile = _profile!.copyWith(
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          fullName: '$firstName $lastName'.trim(),
          phoneNumber: phoneNumber?.trim(),
        );
      } else {
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Changes the customer password with current and new password validation.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiClient.post(
        '/customer/profile/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets state on sign out.
  void clear() {
    _profile = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
