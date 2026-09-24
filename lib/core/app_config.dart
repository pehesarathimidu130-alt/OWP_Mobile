import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

/// Global API configuration for the OWP shared backend.
///
/// Routing strategy:
///   • Web (Chrome dev)     → http://localhost:5131/api
///   • Android Emulator     → http://10.0.2.2:5131/api (loopback alias to host)
///   • Physical device/prod → [productionBaseUrl]
class AppConfig {
  AppConfig._();

  /// The live / staging backend URL (swap this before a real-device build).
  static const String _productionBaseUrl = 'https://api.oleena.lk';

  /// Returns the correct base URL for the current run environment.
  static String get baseUrl {
    if (kIsWeb) {
      // Running on Chrome / Web – the .NET API is on the same machine.
      return 'http://localhost:5131/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator's special alias that routes back to the host machine.
      return 'http://10.0.2.2:5131/api';
    }

    // iOS Simulator or physical device – use the production/staging URL.
    return '$_productionBaseUrl/api';
  }

  // ── Shared-preferences & storage keys ──────────────────────────────────────
  static const String kHasSeenOnboarding = 'hasSeenOnboarding';
  static const String kAuthToken = 'auth_token';
}
