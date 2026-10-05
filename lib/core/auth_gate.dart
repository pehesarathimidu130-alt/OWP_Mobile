import 'package:flutter/material.dart';
import '../widgets/ensure_logged_in.dart';

/// Action-based Auth Gate helper function.
///
/// Thin wrapper around [ensureLoggedIn] for backwards compatibility with existing callers.
/// Verifies if the user is currently authenticated:
/// • If authenticated: Immediately executes [onSuccess].
/// • If guest: Prompts the login gating dialog. If authentication succeeds, executes [onSuccess].
Future<void> requireLogin(
  BuildContext context, {
  required VoidCallback onSuccess,
  String reason = 'Sign in to access this feature',
  IconData icon = Icons.lock_outline_rounded,
}) async {
  final didLogin = await ensureLoggedIn(
    context,
    message: reason,
  );

  if (didLogin && context.mounted) {
    onSuccess();
  }
}

/// Static helper wrapper for object-oriented invocation: `AuthGate.requireLogin(...)`.
class AuthGate {
  AuthGate._();

  static Future<void> requireLogin(
    BuildContext context, {
    required VoidCallback onSuccess,
    String reason = 'Sign in to access this feature',
    IconData icon = Icons.lock_outline_rounded,
  }) =>
      requireLogin(
        context,
        onSuccess: onSuccess,
        reason: reason,
        icon: icon,
      );
}

