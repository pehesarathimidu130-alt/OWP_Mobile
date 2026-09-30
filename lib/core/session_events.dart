import 'dart:async';

/// Centralized session events handler for cross-cutting auth triggers like HTTP 401 Unauthorized.
class SessionEvents {
  SessionEvents._();

  /// Callback registered by the root UI (OleenaApp) to handle session expiration.
  static FutureOr<void> Function()? onUnauthorized;

  /// Guard to prevent multiple simultaneous 401 triggers from causing multiple redirects.
  static bool _isHandlingUnauthorized = false;

  /// Triggered by ApiService when an authenticated request receives a 401 Unauthorized response.
  static Future<void> triggerUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    try {
      if (onUnauthorized != null) {
        await onUnauthorized!();
      }
    } catch (_) {
      // Ignore errors during logout redirect
    }
  }

  /// Resets the unauthorized guard after a successful login or explicit session reset.
  static void resetUnauthorizedGuard() {
    _isHandlingUnauthorized = false;
  }
}
