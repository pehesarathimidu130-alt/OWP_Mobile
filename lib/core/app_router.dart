import 'package:go_router/go_router.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';

import '../screens/main_navigation.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(initialIndex: 0),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const MainNavigation(initialIndex: 0),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const MainNavigation(initialIndex: 1),
    ),
    GoRoute(
      path: '/inquiries',
      builder: (context, state) => const MainNavigation(initialIndex: 2),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainNavigation(initialIndex: 3),
    ),
  ],
);
