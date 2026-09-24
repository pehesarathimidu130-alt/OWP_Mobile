import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/listing_model.dart';

/// Provider managing global favorites state across the application.
class FavoritesProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Listing> _favoriteListings = [];
  final Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  FavoritesProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<Listing> get favoriteListings => List.unmodifiable(_favoriteListings);
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get count => _favoriteListings.length;

  bool isFavorite(int serviceId) => _favoriteIds.contains(serviceId);

  /// Loads the live list of favorite listings from GET /api/favorites.
  Future<void> fetchFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _apiService.getFavoriteListings();
      _favoriteListings = list;
      _favoriteIds.clear();
      for (final item in list) {
        _favoriteIds.add(item.serviceId);
      }
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Optimistically toggles a listing's favorite status.
  /// If the API call fails, reverts the optimistic update and throws the error.
  Future<bool> toggleFavorite(Listing listing) async {
    final serviceId = listing.serviceId;
    final wasFavorited = _favoriteIds.contains(serviceId);
    final targetState = !wasFavorited;

    // 1. Optimistic memory update
    if (targetState) {
      _favoriteIds.add(serviceId);
      if (!_favoriteListings.any((l) => l.serviceId == serviceId)) {
        _favoriteListings.insert(0, listing.copyWith(isFavorite: true));
      }
    } else {
      _favoriteIds.remove(serviceId);
      _favoriteListings.removeWhere((l) => l.serviceId == serviceId);
    }
    notifyListeners();

    // 2. Network sync
    try {
      final confirmedState = await _apiService.toggleFavorite(serviceId);
      if (confirmedState != targetState) {
        // Sync to server response if divergent
        if (confirmedState) {
          _favoriteIds.add(serviceId);
          if (!_favoriteListings.any((l) => l.serviceId == serviceId)) {
            _favoriteListings.insert(0, listing.copyWith(isFavorite: true));
          }
        } else {
          _favoriteIds.remove(serviceId);
          _favoriteListings.removeWhere((l) => l.serviceId == serviceId);
        }
        notifyListeners();
      }
      return confirmedState;
    } catch (e) {
      // 3. Rollback on failure
      if (wasFavorited) {
        _favoriteIds.add(serviceId);
        if (!_favoriteListings.any((l) => l.serviceId == serviceId)) {
          _favoriteListings.insert(0, listing.copyWith(isFavorite: true));
        }
      } else {
        _favoriteIds.remove(serviceId);
        _favoriteListings.removeWhere((l) => l.serviceId == serviceId);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Clears in-memory favorites upon user logout.
  void clear() {
    _favoriteListings = [];
    _favoriteIds.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
