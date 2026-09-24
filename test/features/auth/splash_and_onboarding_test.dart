import 'package:flutter/foundation.dart' show kDebugMode;
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

  FakeAuthProvider({this.isAuthenticated = false, this.token});

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> register(Map<String, dynamic> userData) async {}
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
      // clears hasSeenOnboarding so onboarding is always presented.
      // In release builds, it proceeds directly to /login.
      if (kDebugMode) {
        expect(find.text('Onboarding View'), findsOneWidget);
      } else {
        expect(find.text('Login View'), findsOneWidget);
      }
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
      // clears hasSeenOnboarding so onboarding is always presented.
      // In release builds, it proceeds directly to /home.
      if (kDebugMode) {
        expect(find.text('Onboarding View'), findsOneWidget);
      } else {
        expect(find.text('Home View'), findsOneWidget);
      }
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
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('Login View')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Check first slide content
      expect(find.text('Find Wedding Vendors'), findsOneWidget);
      expect(
        find.text('Discover photographers, musicians, caterers and hotels.'),
        findsOneWidget,
      );
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to move to slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Plan Your Wedding'), findsOneWidget);
      expect(
        find.text('Organize your budget, tasks, timeline and vendors.'),
        findsOneWidget,
      );

      // Tap Next to move to slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get AI Recommendations'), findsOneWidget);
      expect(
        find.text(
            'Let AI help create a wedding plan based on your requirements.'),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify routed to /login
      expect(find.text('Login View'), findsOneWidget);

      // Verify SharedPreferences flag was updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hasSeenOnboarding'), isTrue);
    });

    testWidgets('tapping Skip sets flag and navigates to /login immediately',
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
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('Login View')),
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

      expect(find.text('Login View'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hasSeenOnboarding'), isTrue);
    });
  });
}
