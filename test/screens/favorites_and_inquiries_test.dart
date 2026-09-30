import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/core/api_service.dart';
import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/core/favorites_provider.dart';
import 'package:oleena/core/inquiry_api_service.dart';
import 'package:oleena/models/inquiry_model.dart';
import 'package:oleena/models/listing_model.dart';
import 'package:oleena/screens/favorites/favorites_screen.dart';
import 'package:oleena/widgets/listing_card.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  final bool _auth;
  MockAuthProvider([this._auth = true]);

  @override
  bool get isAuthenticated => _auth;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFavoritesProvider extends ChangeNotifier implements FavoritesProvider {
  final Set<int> _favs = {};
  String? _error;
  List<Listing> _listings = [];

  MockFavoritesProvider({Set<int>? favs, String? error, List<Listing>? listings}) {
    if (favs != null) _favs.addAll(favs);
    _error = error;
    if (listings != null) _listings = listings;
  }

  @override
  bool isFavorite(int serviceId) => _favs.contains(serviceId);

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => _error;

  @override
  List<Listing> get favoriteListings => _listings;

  int fetchFavoritesCalls = 0;

  @override
  Future<void> fetchFavorites() async {
    fetchFavoritesCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeApiService implements ApiService {
  int getInquiriesCalls = 0;

  @override
  String get baseUrl => 'http://localhost:5131/api';

  @override
  Future<List<Inquiry>> getMyInquiries() async {
    getInquiriesCalls++;
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyListing = Listing(
    id: '42',
    serviceId: 42,
    title: 'Grand Ballroom Celebration Package',
    category: 'Hotel / Venue',
    categoryId: 1,
    categoryIcon: 'location_city',
    shortDescription: 'Luxury venue.',
    description: 'Detailed description.',
    price: 300000,
    priceFrom: 300000,
    isPriceOnRequest: false,
    coverImageUrl: 'https://example.com/cover.jpg',
    images: const [],
    vendor: VendorInfo(
      id: '1',
      vendorId: 1,
      name: 'Grand Colombo Venue',
      location: 'Colombo',
      rating: 4.8,
      reviewCount: 24,
      city: 'Colombo',
    ),
    isFavorite: true, // Model field is true, but provider may not have it
  );

  group('ListingCard Heart Binding', () {
    testWidgets('heart icon is strictly driven by FavoritesProvider, not model isFavorite fallback', (tester) async {
      // Provider does NOT contain serviceId 42, but listing.isFavorite is true
      final favProvider = MockFavoritesProvider(favs: {});
      final authProvider = MockAuthProvider(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(listing: dummyListing),
            ),
          ),
        ),
      );

      // Since provider does not have it, heart icon must be favorite_border (unselected)
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    });

    testWidgets('heart icon is filled when FavoritesProvider contains serviceId', (tester) async {
      final favProvider = MockFavoritesProvider(favs: {42});
      final authProvider = MockAuthProvider(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(listing: dummyListing),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });
  });

  group('FavoritesScreen Friendly Error Messages and Empty State', () {
    testWidgets('renders friendly network error message with Retry button', (tester) async {
      final favProvider = MockFavoritesProvider(
        error: 'SocketException: Failed host lookup: cannot reach backend',
      );
      final authProvider = MockAuthProvider(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );

      expect(find.text('Unable to Load Favourites'), findsOneWidget);
      expect(find.text('Could not reach the server. Please check your connection.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      final initialCalls = favProvider.fetchFavoritesCalls;
      await tester.tap(find.text('Retry'));
      expect(favProvider.fetchFavoritesCalls, equals(initialCalls + 1));
    });

    testWidgets('renders friendly 401 session expired message with Retry button', (tester) async {
      final favProvider = MockFavoritesProvider(
        error: 'ApiException: 401 Unauthorized',
      );
      final authProvider = MockAuthProvider(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );

      expect(find.text('Your session has expired. Please sign in again.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders friendly 5xx server error message with Retry button', (tester) async {
      final favProvider = MockFavoritesProvider(
        error: 'ApiException: 500 Internal Server Error',
      );
      final authProvider = MockAuthProvider(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );

      expect(find.text('Server error. Please try again later.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders friendly empty state when list is empty without errors', (tester) async {
      final favProvider = MockFavoritesProvider(listings: []);
      final authProvider = MockAuthProvider(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );

      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.text('Start Exploring'), findsOneWidget);
    });
  });

  group('InquiryApiService Delegation', () {
    test('InquiryApiService delegates getMyInquiries to ApiService directly', () async {
      final fakeApi = FakeApiService();
      final inquiryService = InquiryApiService(apiService: fakeApi);

      await inquiryService.getMyInquiries();

      expect(fakeApi.getInquiriesCalls, equals(1));
    });
  });
}
