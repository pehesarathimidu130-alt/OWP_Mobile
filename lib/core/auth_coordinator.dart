import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

/// Central coordinator for guest login/register modal flows and return-to-origin navigation.
///
/// Handles push/pushReplacement transitions between Login and Register screens without
/// losing the flow's completion state, and pops back to the originating screen on success.
class AuthCoordinator {
  AuthCoordinator._();

  static Completer<bool>? _completer;
  static int _mountedAuthScreens = 0;
  static bool _hasSucceeded = false;

  /// Returns true if an auth flow is currently in progress.
  static bool get isFlowActive => _completer != null && !_completer!.isCompleted;

  /// Called in initState of LoginScreen and RegisterScreen.
  static void screenMounted() {
    _mountedAuthScreens++;
  }

  /// Called in dispose of LoginScreen and RegisterScreen.
  /// When all auth screens have unmounted without a success notification, completes false.
  static void screenUnmounted() {
    _mountedAuthScreens--;
    if (_mountedAuthScreens <= 0) {
      _mountedAuthScreens = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mountedAuthScreens == 0 && !_hasSucceeded) {
          if (_completer != null && !_completer!.isCompleted) {
            _completer!.complete(false);
          }
          _completer = null;
        }
      });
    }
  }

  /// Starts the auth flow, pushing the appropriate screen, and returns a `Future<bool>`
  /// that completes with true on success or false when dismissed.
  static Future<bool> startFlow(BuildContext context, {bool isRegister = false}) {
    _completer = Completer<bool>();
    _hasSucceeded = false;

    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: isRegister ? 'auth_register' : 'auth_login'),
        builder: (_) => isRegister ? const RegisterScreen() : const LoginScreen(),
      ),
    );

    return _completer!.future;
  }

  /// Called on successful authentication (Login, Register, or Google sign-in).
  ///
  /// Completes the pending flow with true, pops all mounted auth screens back to the
  /// originating screen if one exists, or navigates to /home if started on a cold route.
  static void notifySuccess(BuildContext context) {
    _hasSucceeded = true;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(true);
    }
    _completer = null;

    final navigator = Navigator.of(context);
    bool hasNonAuthOrigin = false;

    if (navigator.canPop()) {
      navigator.popUntil((route) {
        final name = route.settings.name;
        final isAuth = name == 'auth_login' ||
            name == 'auth_register' ||
            name == '/login' ||
            name == '/register';
        if (!isAuth) {
          hasNonAuthOrigin = true;
          return true;
        }
        return route.isFirst;
      });
    }

    if (!hasNonAuthOrigin) {
      if (context.mounted) {
        context.go('/home');
      }
    }
  }

  /// Resets coordinator state for clean unit and widget testing.
  @visibleForTesting
  static void reset() {
    _completer = null;
    _mountedAuthScreens = 0;
    _hasSucceeded = false;
  }
}
