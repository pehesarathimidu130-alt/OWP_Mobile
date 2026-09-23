import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/features/auth/screens/login_screen.dart';
import 'package:oleena/features/auth/screens/register_screen.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool isLoading = false;
  @override
  bool isAuthenticated = false;
  @override
  String? token;

  String? lastLoginEmail;
  String? lastLoginPassword;
  Map<String, dynamic>? lastRegisterData;

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> login(String email, String password) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    throw UnimplementedError('Login is not yet implemented.');
  }

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    lastRegisterData = userData;
    throw UnimplementedError('Register is not yet implemented.');
  }

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthProvider mockAuth;

  setUp(() {
    mockAuth = MockAuthProvider();
  });

  Widget buildTestableWidget(Widget child, {GoRouter? router}) {
    final effectiveRouter = router ??
        GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => child),
            GoRoute(
              path: '/forgot-password',
              builder: (context, state) =>
                  const Scaffold(body: Text('Forgot Password View')),
            ),
            GoRoute(
              path: '/register',
              builder: (context, state) =>
                  const Scaffold(body: Text('Register View')),
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

    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp.router(
        routerConfig: effectiveRouter,
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders all expected fields and widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('shows validation errors only after submit attempt',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      // Initially no error messages
      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Password is required'), findsNothing);

      // Tap Login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Error messages appear inline
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final emailField = find.widgetWithText(TextFormField, '');
      await tester.enterText(emailField.first, 'invalidemail');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets(
        'valid submit calls login and shows unhandled UnimplementedError SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.enterText(textFields.at(1), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(mockAuth.lastLoginEmail, 'user@example.com');
      expect(mockAuth.lastLoginPassword, 'password123');

      await tester.pumpAndSettle();
      expect(
        find.text("Login isn't connected to the backend yet."),
        findsOneWidget,
      );
    });

    testWidgets('navigates to /forgot-password when clicked',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password View'), findsOneWidget);
    });

    testWidgets('navigates to /register when clicked',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Register View'), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders all registration fields and widgets',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));

      expect(find.text('Create Account'), findsNWidgets(2)); // Title & Button
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Create Account'),
        findsOneWidget,
      );
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit attempt',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('validates password min length and mismatch',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), 'jane@example.com');
      await tester.enterText(textFields.at(2), '0712345678');
      await tester.enterText(textFields.at(3), 'short');
      await tester.enterText(textFields.at(4), 'mismatch');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets(
        'valid submit calls register and shows UnimplementedError SnackBar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), 'jane@example.com');
      await tester.enterText(textFields.at(2), '0712345678');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      expect(mockAuth.lastRegisterData?['name'], 'Jane Doe');
      expect(mockAuth.lastRegisterData?['email'], 'jane@example.com');
      expect(mockAuth.lastRegisterData?['phone'], '0712345678');
      expect(mockAuth.lastRegisterData?['password'], 'password123');

      await tester.pumpAndSettle();
      expect(
        find.text("Registration isn't connected to the backend yet."),
        findsOneWidget,
      );
    });

    testWidgets('navigates to /login when Login link is clicked',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Login View'), findsOneWidget);
    });
  });
}
