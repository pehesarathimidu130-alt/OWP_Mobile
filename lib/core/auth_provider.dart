import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// Provider managing authentication state, customer profile data, and JWT tokens.
class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  final ApiClient _apiClient;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  String? _fullName;
  String? _email;
  String? _role;
  int? _customerId;

  AuthProvider({FlutterSecureStorage? storage, ApiClient? apiClient})
      : _storage = storage ?? const FlutterSecureStorage(),
        _apiClient = apiClient ?? ApiClient();

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;
  int? get customerId => _customerId;

  /// User-friendly display name (prioritizes fullName, then email prefix, then fallback)
  String get displayName {
    if (_fullName != null && _fullName!.trim().isNotEmpty) {
      return _fullName!.trim();
    }
    if (_email != null && _email!.trim().isNotEmpty) {
      return _email!.split('@').first;
    }
    return 'Oleena Member';
  }

  /// Initials derived from display name (e.g. "Vinu Senarathne" -> "VS")
  String get userInitials {
    final name = displayName.trim();
    if (name.isEmpty) return 'O';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Checks whether a stored JWT token exists and restores session & user details.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storedToken = await _storage.read(key: 'auth_token');
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;
        _isAuthenticated = true;

        // Restore stored user metadata
        _fullName = await _storage.read(key: 'user_full_name');
        _email = await _storage.read(key: 'user_email');
        _role = await _storage.read(key: 'user_role');

        // If metadata is missing from storage, decode from JWT claims
        if (_fullName == null || _email == null) {
          _extractFromJwt(storedToken);
        }
      } else {
        _token = null;
        _isAuthenticated = false;
        _fullName = null;
        _email = null;
      }
    } catch (_) {
      _token = null;
      _isAuthenticated = false;
      _fullName = null;
      _email = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User login - extracts and persists user details from .NET backend response.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post('/auth/customer/login', body: {
        'email': email,
        'password': password,
      });

      if (response != null && response is Map<String, dynamic>) {
        await _handleAuthSuccess(response, fallbackEmail: email);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User registration - extracts and persists user details from .NET backend response.
  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      dynamic response;
      try {
        response = await _apiClient.post('/auth/register', body: userData);
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          response = await _apiClient.post('/auth/customer/register', body: userData);
        } else {
          rethrow;
        }
      }

      if (response != null && response is Map<String, dynamic>) {
        await _handleAuthSuccess(
          response,
          fallbackName: userData['fullName'] ?? userData['name'],
          fallbackEmail: userData['email'],
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Processes successful auth response, extracting token and user identity.
  Future<void> _handleAuthSuccess(
    Map<String, dynamic> response, {
    String? fallbackName,
    String? fallbackEmail,
  }) async {
    final token = response['token']?.toString();
    if (token != null && token.isNotEmpty) {
      _token = token;
      _isAuthenticated = true;
      await _storage.write(key: 'auth_token', value: token);

      // Extract fullName, email, role, customerId from response body
      final name = response['fullName']?.toString() ??
          response['name']?.toString() ??
          fallbackName;
      final email = response['email']?.toString() ?? fallbackEmail;
      final role = response['role']?.toString() ?? 'Customer';
      final customerId = response['customerId'];

      _fullName = name;
      _email = email;
      _role = role;
      if (customerId is int) _customerId = customerId;

      // Also parse token claims if still missing
      if (_fullName == null || _email == null) {
        _extractFromJwt(token);
      }

      // Persist user profile fields
      if (_fullName != null) {
        await _storage.write(key: 'user_full_name', value: _fullName!);
      }
      if (_email != null) {
        await _storage.write(key: 'user_email', value: _email!);
      }
      if (_role != null) {
        await _storage.write(key: 'user_role', value: _role!);
      }
    }
  }

  /// Decodes payload claims from JWT token as fallback.
  void _extractFromJwt(String jwtToken) {
    try {
      final parts = jwtToken.split('.');
      if (parts.length != 3) return;
      final normalized = base64Url.normalize(parts[1]);
      final decodedJson = utf8.decode(base64Url.decode(normalized));
      final claims = jsonDecode(decodedJson) as Map<String, dynamic>?;

      if (claims != null) {
        _fullName ??= claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']?.toString() ??
            claims['name']?.toString() ??
            claims['fullName']?.toString();

        _email ??= claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']?.toString() ??
            claims['email']?.toString();

        _role ??= claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString() ??
            claims['role']?.toString();
      }
    } catch (_) {
      // Ignored if malformed
    }
  }

  /// Logs out the user and clears stored credentials.
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_full_name');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_role');

    _token = null;
    _fullName = null;
    _email = null;
    _role = null;
    _customerId = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
