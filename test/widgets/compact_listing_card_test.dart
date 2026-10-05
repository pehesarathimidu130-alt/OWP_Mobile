import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/models/listing_model.dart';
import 'package:oleena/widgets/compact_listing_card.dart';
import 'package:provider/provider.dart';
import 'package:oleena/core/favorites_provider.dart';
import 'package:oleena/core/auth_provider.dart';

class MockFavoritesProvider extends ChangeNotifier implements FavoritesProvider {
  final Set<int> _favs = {1};

  @override
  bool isFavorite(int serviceId) => _favs.contains(serviceId);

  @override
  Future<bool> toggleFavorite(Listing listing) async {
    if (_favs.contains(listing.serviceId)) {
      _favs.remove(listing.serviceId);
      notifyListeners();
      return false;
    } else {
      _favs.add(listing.serviceId);
      notifyListeners();
      return true;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool get isAuthenticated => true;

  @override
  String? get profilePhotoUrl => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testListing = Listing(
    id: '1',
    serviceId: 1,
    title: 'Very Long Grand Luxury Ballroom Package For Wedding Celebrations And Gala Dinners',
    category: 'Hotel / Venue',
    categoryId: 1,
    categoryIcon: 'location_city',
    shortDescription: 'Luxury wedding venue in Colombo.',
    description: 'Detailed description.',
    price: 350000,
    priceFrom: 350000,
    isPriceOnRequest: false,
    coverImageUrl: 'https://example.com/cover.jpg',
    images: const [],
    vendor: VendorInfo(
      id: '10',
      vendorId: 10,
      name: 'Shangri-La Colombo Grand Luxury Resorts',
      location: 'Colombo, Sri Lanka',
      rating: 4.9,
      reviewCount: 42,
      isApproved: true,
    ),
    isFavorite: false, // Notice listing.isFavorite is false, but FavoritesProvider.isFavorite is true
  );

  Widget buildCardAtScale(double fontScale) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritesProvider>(create: (_) => MockFavoritesProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: const Size(400, 800),
              textScaler: TextScaler.linear(fontScale),
            ),
            child: Builder(
              builder: (context) {
                final textScaler = MediaQuery.textScalerOf(context);
                const double imageHeight = 130.0;
                const double baseTextBlockHeight = 125.0;
                final double scaledTextBlockHeight = textScaler.scale(baseTextBlockHeight);
                final double mainAxisExtent = imageHeight + scaledTextBlockHeight;

                return Center(
                  child: SizedBox(
                    width: 180,
                    height: mainAxisExtent,
                    child: CompactListingCard(listing: testListing),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('CompactListingCard renders without overflow at 1.0x text scale', (tester) async {
    await tester.pumpWidget(buildCardAtScale(1.0));
    await tester.pumpAndSettle();

    // Verify no overflow exception was thrown
    expect(tester.takeException(), isNull);
    expect(find.byType(CompactListingCard), findsOneWidget);
    // Verify heart icon is driven ONLY by FavoritesProvider (which has serviceId 1 in _favs)
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('CompactListingCard renders without overflow at 1.3x text scale with 2-line title', (tester) async {
    await tester.pumpWidget(buildCardAtScale(1.3));
    await tester.pumpAndSettle();

    // Verify no overflow exception was thrown even at 1.3x text scale
    expect(tester.takeException(), isNull);
    expect(find.byType(CompactListingCard), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('Heart icon is driven strictly by FavoritesProvider without fallback', (tester) async {
    final nonFavListing = testListing.copyWith(serviceId: 999, isFavorite: true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoritesProvider>(create: (_) => MockFavoritesProvider()),
          ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 280,
              child: CompactListingCard(listing: nonFavListing),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Even though nonFavListing.isFavorite is true, FavoritesProvider does not contain 999,
    // so heart MUST be favorite_border_rounded (unselected).
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
  });
}
