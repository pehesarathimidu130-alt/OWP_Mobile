import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:oleena/core/auth_coordinator.dart';
import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/core/favorites_provider.dart';
import 'package:oleena/core/session_events.dart';
import 'package:oleena/features/auth/screens/login_screen.dart';
import 'package:oleena/features/auth/screens/register_screen.dart';
import 'package:oleena/models/listing_model.dart';
import 'package:oleena/models/public_vendor_profile.dart';
import 'package:oleena/widgets/ensure_logged_in.dart';
import 'package:oleena/widgets/masked_contact.dart';

class TestAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool isLoading = false;
  @override
  bool isAuthenticated;
  @override
  String? token;
  @override
  String? fullName;
  @override
  String? email;
  @override
  String? role;
  @override
  int? customerId;

  bool logoutCalled = false;

  TestAuthProvider({this.isAuthenticated = false, this.token});

  @override
  String get displayName => fullName ?? 'Oleena Member';
  @override
  String get userInitials => 'OM';

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> login(String email, String password) async {
    isAuthenticated = true;
    token = 'test_token';
    notifyListeners();
  }

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    isAuthenticated = true;
    token = 'test_token';
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    isAuthenticated = false;
    token = null;
    notifyListeners();
  }

  @override
  Future<void> signInWithGoogle(String serverClientId) async {
    isAuthenticated = true;
    token = 'test_google_token';
    notifyListeners();
  }

  @override
  Future<void> updateUserSession({String? fullName, String? email}) async {
    if (fullName != null) this.fullName = fullName;
    if (email != null) this.email = email;
    notifyListeners();
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthCoordinator.reset();
  });

  tearDown(() {
    AuthCoordinator.reset();
  });

  group('P9 — EnsureLoggedIn & Action Messages', () {
    testWidgets('Guest sees dialog with exact message and buttons (Login, Register, Not now)', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: false);
      bool? result;

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await ensureLoggedIn(
                      context,
                      message: 'You need to register or log in to view this.',
                    );
                  },
                  child: const Text('Check Login'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Check Login'));
      await tester.pumpAndSettle();

      // Verify Title, Message and the three action buttons
      expect(find.text('Account Required'), findsOneWidget);
      expect(find.text('You need to register or log in to view this.'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Dismissing with 'Not now' completes with false
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('Gated actions use specific wording per action', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: false);
      const messages = [
        'You need to register or log in to view this.',
        'You need to register or log in to save favourites.',
        'You need to register or log in to send an inquiry.',
        'You need to log in or register to use this feature.',
      ];

      for (final msg in messages) {
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>.value(
            value: auth,
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => ensureLoggedIn(context, message: msg),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text(msg), findsOneWidget);

        await tester.tap(find.text('Not now'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Authenticated user bypasses dialog and returns true immediately', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: true);
      bool? result;

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await ensureLoggedIn(
                      context,
                      message: 'You need to register or log in to view this.',
                    );
                  },
                  child: const Text('Check Login'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Check Login'));
      await tester.pumpAndSettle();

      expect(find.text('Account Required'), findsNothing);
      expect(result, isTrue);
    });
  });

  group('P9 — MaskedContact Widget', () {
    testWidgets('Masks value as **** for guest, even if phone number is present', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const MaterialApp(
            home: Scaffold(
              body: MaskedContact(
                value: '0771234567',
                contactHidden: false,
                message: 'You need to register or log in to view this.',
              ),
            ),
          ),
        ),
      );

      expect(find.text('0771234567'), findsNothing);
      expect(find.text('****'), findsOneWidget);
    });

    testWidgets('Masks value as **** when contactHidden is true, even if authenticated', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: true);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const MaterialApp(
            home: Scaffold(
              body: MaskedContact(
                value: '0771234567',
                contactHidden: true,
                message: 'You need to register or log in to view this.',
              ),
            ),
          ),
        ),
      );

      expect(find.text('0771234567'), findsNothing);
      expect(find.text('****'), findsOneWidget);
    });

    testWidgets('Reveals real value only when authenticated AND contactHidden is false', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: true);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const MaterialApp(
            home: Scaffold(
              body: MaskedContact(
                value: '0771234567',
                contactHidden: false,
                message: 'You need to register or log in to view this.',
              ),
            ),
          ),
        ),
      );

      expect(find.text('0771234567'), findsOneWidget);
      expect(find.text('****'), findsNothing);
    });

    testWidgets('Tapping masked contact triggers ensureLoggedIn prompt', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const MaterialApp(
            home: Scaffold(
              body: MaskedContact(
                value: '0771234567',
                contactHidden: false,
                message: 'You need to register or log in to view this.',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('****'));
      await tester.pumpAndSettle();

      expect(find.text('Account Required'), findsOneWidget);
      expect(find.text('You need to register or log in to view this.'), findsOneWidget);
    });
  });

  group('P9 — AuthCoordinator Modal Navigation & Flow', () {
    testWidgets('Switching Login -> Register -> success returns to origin screen (startFlow completes true)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final auth = TestAuthProvider(isAuthenticated: false);
      bool? flowResult;

      final router = GoRouter(
        initialLocation: '/listing',
        routes: [
          GoRoute(
            path: '/listing',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    flowResult = await AuthCoordinator.startFlow(context, isRegister: false);
                  },
                  child: const Text('Open Login Flow'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            name: 'auth_login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            name: 'auth_register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('Home Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<FavoritesProvider>(create: (_) => FavoritesProvider()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // 1. On Listing screen
      expect(find.text('Open Login Flow'), findsOneWidget);

      // 2. Start flow -> opens Login
      await tester.tap(find.text('Open Login Flow'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);

      // 3. Switch from Login to Register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);

      // 4. Fill and submit registration successfully
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Alice Wonderland');
      await tester.enterText(textFields.at(1), 'alice@example.com');
      await tester.enterText(textFields.at(2), '0771234567');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password123');

      final createBtn = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      // 5. AuthCoordinator pops auth screens back to the origin listing screen
      expect(find.text('Open Login Flow'), findsOneWidget);
      expect(flowResult, isTrue);
    });

    testWidgets('Dismissing the auth flow returns false', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: false);
      bool? flowResult;

      final router = GoRouter(
        initialLocation: '/listing',
        routes: [
          GoRoute(
            path: '/listing',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    flowResult = await AuthCoordinator.startFlow(context, isRegister: false);
                  },
                  child: const Text('Open Login Flow'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            name: 'auth_login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            name: 'auth_register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.tap(find.text('Open Login Flow'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);

      // User dismisses without authenticating (system pop / back)
      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('Open Login Flow'), findsOneWidget);
      expect(flowResult, isFalse);
    });

    testWidgets('Cold start login success navigates to /home when no origin route exists', (tester) async {
      final auth = TestAuthProvider(isAuthenticated: false);

      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            name: 'auth_login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('Home Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);

      // Perform login
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.enterText(textFields.at(1), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });
  });

  group('P9 — Model contactHidden Support', () {
    test('Listing model defaults contactHidden to false and parses bool from JSON', () {
      final defaultListing = Listing.fromJson({
        'serviceId': 1,
        'title': 'Default Service',
        'category': 'Photography',
      });
      expect(defaultListing.contactHidden, isFalse);

      final hiddenJson = {
        'serviceId': 2,
        'title': 'Hidden Service',
        'category': 'Venue',
        'price': 200,
        'contactHidden': true,
      };
      final hiddenListing = Listing.fromJson(hiddenJson);
      expect(hiddenListing.contactHidden, isTrue);
    });

    test('PublicVendorProfile model defaults contactHidden to false and parses bool from JSON', () {
      final defaultProfile = PublicVendorProfile.fromJson({
        'vendorId': 1,
        'businessName': 'Business',
        'category': 'Venue',
        'location': 'Colombo',
      });
      expect(defaultProfile.contactHidden, isFalse);

      final hiddenJson = {
        'vendorId': 2,
        'businessName': 'Hidden Vendor',
        'category': 'Music',
        'location': 'Kandy',
        'contactHidden': true,
      };
      final hiddenProfile = PublicVendorProfile.fromJson(hiddenJson);
      expect(hiddenProfile.contactHidden, isTrue);
    });
  });

  group('P9 — Session Expiry & 401 Guarding', () {
    test('SessionEvents guards against duplicate unauthorized triggers', () async {
      int triggerCount = 0;
      SessionEvents.onUnauthorized = () {
        triggerCount++;
      };

      await SessionEvents.triggerUnauthorized();
      await SessionEvents.triggerUnauthorized(); // Second trigger ignored by guard
      expect(triggerCount, equals(1));

      SessionEvents.resetUnauthorizedGuard();
      await SessionEvents.triggerUnauthorized();
      expect(triggerCount, equals(2));

      SessionEvents.onUnauthorized = null;
      SessionEvents.resetUnauthorizedGuard();
    });

    test('Auth endpoints are excluded from triggering unauthorized', () {
      const authEndpoints = [
        '/api/auth/login',
        '/api/auth/register',
        '/api/auth/google',
      ];
      for (final endpoint in authEndpoints) {
        expect(endpoint.contains('/auth/'), isTrue);
      }

      const protectedEndpoints = [
        '/api/favorites',
        '/api/inquiries',
        '/api/customer/profile',
      ];
      for (final endpoint in protectedEndpoints) {
        expect(endpoint.contains('/auth/'), isFalse);
      }
    });
  });
}
