import 'package:flutter/foundation.dart';
import '../../../core/api_client.dart';

/// Manages customer notification preference toggles connected to the backend.
///
/// Optimistic toggle updates with rollback on failure.
class NotificationPreferencesProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  bool _inquiryUpdates = true;
  bool _priceChanges = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get inquiryUpdates => _inquiryUpdates;
  bool get priceChanges => _priceChanges;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationPreferencesProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches preferences from GET /api/customer/notification-preferences.
  Future<void> fetchPreferences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/customer/notification-preferences');
      if (response != null && response is Map<String, dynamic>) {
        _inquiryUpdates = response['inquiryUpdates'] == true || response['inquiryUpdates'] == null;
        _priceChanges = response['priceChanges'] == true || response['priceChanges'] == null;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load notification preferences.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles the Inquiry Updates notification preference optimistically.
  Future<void> toggleInquiryUpdates(bool value) async {
    final previous = _inquiryUpdates;
    _inquiryUpdates = value;
    notifyListeners();

    try {
      await _apiClient.put(
        '/customer/notification-preferences',
        body: {
          'inquiryUpdates': value,
          'priceChanges': _priceChanges,
        },
      );
    } catch (e) {
      _inquiryUpdates = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// Toggles the Favourite Price Changes notification preference optimistically.
  Future<void> togglePriceChanges(bool value) async {
    final previous = _priceChanges;
    _priceChanges = value;
    notifyListeners();

    try {
      await _apiClient.put(
        '/customer/notification-preferences',
        body: {
          'inquiryUpdates': _inquiryUpdates,
          'priceChanges': value,
        },
      );
    } catch (e) {
      _priceChanges = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// Resets state on sign out.
  void clear() {
    _inquiryUpdates = true;
    _priceChanges = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
