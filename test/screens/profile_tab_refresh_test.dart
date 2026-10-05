import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/core/favorites_provider.dart';
import 'package:oleena/features/profile/providers/customer_profile_provider.dart';
import 'package:oleena/models/customer_profile_model.dart';
import 'package:oleena/screens/profile/profile_screen.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  bool _authenticated;
  MockAuthProvider([this._authenticated = true]);

  @override
  bool get isAuthenticated => _authenticated;

  set authenticated(bool val) {
    _authenticated = val;
    notifyListeners();
  }

  @override
  String get displayName => 'Test User';

  @override
  String get userInitials => 'TU';

  @override
  String? get email => 'test@example.com';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFavoritesProvider extends ChangeNotifier implements FavoritesProvider {
  @override
  int get count => 3;

  @override
  bool isFavorite(int serviceId) => false;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestCustomerProfileProvider extends ChangeNotifier implements CustomerProfileProvider {
  int fetchProfileCalls = 0;
  CustomerProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  CustomerProfile? get profile => _profile;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<void> fetchProfile() async {
    fetchProfileCalls++;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('ProfileScreen does NOT fetch profile when inactive on initial build', (tester) async {
    final mockAuth = MockAuthProvider(true);
    final mockFav = MockFavoritesProvider();
    final profileProvider = TestCustomerProfileProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<FavoritesProvider>.value(value: mockFav),
          ChangeNotifierProvider<CustomerProfileProvider>.value(value: profileProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(isActive: false),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(profileProvider.fetchProfileCalls, equals(0),
        reason: 'Should not fetch profile when tab is inactive initially');
  });

  testWidgets('ProfileScreen fetches profile when tab becomes active and authenticated, and not twice', (tester) async {
    final mockAuth = MockAuthProvider(true);
    final mockFav = MockFavoritesProvider();
    final profileProvider = TestCustomerProfileProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<FavoritesProvider>.value(value: mockFav),
          ChangeNotifierProvider<CustomerProfileProvider>.value(value: profileProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(isActive: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(profileProvider.fetchProfileCalls, equals(0));

    // Transition tab to active: true
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<FavoritesProvider>.value(value: mockFav),
          ChangeNotifierProvider<CustomerProfileProvider>.value(value: profileProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(isActive: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(profileProvider.fetchProfileCalls, equals(1),
        reason: 'Should fetch profile exactly once on becoming active');

    // Re-pump while still active: true
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<FavoritesProvider>.value(value: mockFav),
          ChangeNotifierProvider<CustomerProfileProvider>.value(value: profileProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(isActive: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(profileProvider.fetchProfileCalls, equals(1),
        reason: 'Must NOT fetch profile a second time if already active');
  });

  testWidgets('ProfileScreen does NOT fetch profile when unauthenticated (guest)', (tester) async {
    final mockAuth = MockAuthProvider(false); // Guest
    final mockFav = MockFavoritesProvider();
    final profileProvider = TestCustomerProfileProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<FavoritesProvider>.value(value: mockFav),
          ChangeNotifierProvider<CustomerProfileProvider>.value(value: profileProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(isActive: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Transition tab to active
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<FavoritesProvider>.value(value: mockFav),
          ChangeNotifierProvider<CustomerProfileProvider>.value(value: profileProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(isActive: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(profileProvider.fetchProfileCalls, equals(0),
        reason: 'Guest users must not trigger profile fetch');
  });
}
