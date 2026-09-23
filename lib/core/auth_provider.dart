import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// Provider managing authentication state and JWT tokens.
class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  final ApiClient _apiClient;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;

  AuthProvider({FlutterSecureStorage? storage, ApiClient? apiClient})
      : _storage = storage ?? const FlutterSecureStorage(),
        _apiClient = apiClient ?? ApiClient();

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  /// Checks whether a stored JWT token exists and validates auth status.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storedToken = await _storage.read(key: 'auth_token');
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;
        _isAuthenticated = true;
      } else {
        _token = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      _token = null;
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User login - wired with OWP_Backend API.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post('/auth/customer/login', body: {
        'email': email,
        'password': password,
      });
      if (response != null && response['token'] != null) {
        final String newToken = response['token'];
        await _storage.write(key: 'auth_token', value: newToken);
        _token = newToken;
        _isAuthenticated = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User registration - wired with OWP_Backend API.
  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post('/auth/customer/register', body: userData);
      if (response != null && response['token'] != null) {
        final String newToken = response['token'];
        await _storage.write(key: 'auth_token', value: newToken);
        _token = newToken;
        _isAuthenticated = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out the user and clears stored credentials.
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
