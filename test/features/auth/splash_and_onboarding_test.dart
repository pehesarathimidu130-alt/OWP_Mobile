import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/features/auth/screens/onboarding_screen.dart';
import 'package:oleena/features/auth/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
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
  @override
  String? profilePhotoUrl;
  @override
  String get displayName => fullName ?? 'Oleena Member';
  @override
  String get userInitials => 'OM';

  FakeAuthProvider({this.isAuthenticated = false, this.token, this.fullName, this.email});

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> register(Map<String, dynamic> userData) async {}

  @override
  Future<void> signInWithGoogle(String serverClientId) async {}

  @override
  Future<void> updateUserSession({String? fullName, String? email}) async {
    if (fullName != null) this.fullName = fullName;
    if (email != null) this.email = email;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen', () {
    testWidgets('renders brand title and loading indicator',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': false});

      final authProvider = FakeAuthProvider(isAuthenticated: false);

      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding View')),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('Login View')),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('Home View')),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Check initial UI elements
      expect(find.text('OLEENA'), findsOneWidget);
      expect(find.text('Wedding Planner'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Allow postFrameCallback to fire
      await tester.pump();
      // Advance clock past the 1200ms minimum delay
      await tester.pump(const Duration(milliseconds: 1300));
      // Pump transition frame
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Since hasSeenOnboarding is false, should navigate to /onboarding
      expect(find.text('Onboarding View'), findsOneWidget);
    });

    testWidgets('navigates to /login when onboarding seen but not authenticated',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});

      final authProvider = FakeAuthProvider(isAuthenticated: false);

      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding View')),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('Login View')),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('Home View')),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Allow postFrameCallback to fire
      await tester.pump();
      // Advance past delay
      await tester.pump(const Duration(milliseconds: 1300));
      // Pump transition frame
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // In guest-first flow, SplashScreen proceeds directly to /home when onboarding was seen.
      expect(find.text('Home View'), findsOneWidget);
    });

    testWidgets('navigates to /home when onboarding seen and authenticated',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});

      final authProvider = FakeAuthProvider(isAuthenticated: true, token: 'fake_jwt');

      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding View')),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('Home View')),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('Login View')),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Allow postFrameCallback to fire
      await tester.pump();
      // Advance past delay
      await tester.pump(const Duration(milliseconds: 1300));
      // Pump transition frame
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // In kDebugMode (during development and widget tests), SplashScreen
      // In guest-first flow, proceeds to /home.
      expect(find.text('Home View'), findsOneWidget);
    });
  });

  group('OnboardingScreen', () {
    testWidgets('renders slides and navigates to /login on Skip',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': false});

      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('Home View')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Check first slide content (Stitch AI Onboarding Page 1: Discover)
      expect(find.text('DISCOVER'), findsOneWidget);
      expect(find.text('Everything for your big day, in one place'), findsOneWidget);
      expect(
        find.text('Venues, photographers, florists, caterers and bands, all waiting to meet you.'),
        findsOneWidget,
      );
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to move to slide 2 (Stitch AI Onboarding Page 2: Shortlist)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('SHORTLIST'), findsOneWidget);
      expect(find.text('Save what you love, ask the vendor directly'), findsOneWidget);
      expect(
        find.text('Tap the heart on your favourites, then send an inquiry in a few taps.'),
        findsOneWidget,
      );

      // Tap Next to move to slide 3 (Stitch AI Onboarding Page 3: Intelligent Planning)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('INTELLIGENT PLANNING'), findsOneWidget);
      expect(find.text('Plan together with AI'), findsOneWidget);
      expect(
        find.text(
            "Tell us your date, budget and style. We'll suggest a plan, step by step."),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify routed to /home
      expect(find.text('Home View'), findsOneWidget);

      // Verify SharedPreferences flag was updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hasSeenOnboarding'), isTrue);
    });

    testWidgets('tapping Skip sets flag and navigates to /home immediately',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': false});

      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('Home View')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Home View'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hasSeenOnboarding'), isTrue);
    });
  });
}
