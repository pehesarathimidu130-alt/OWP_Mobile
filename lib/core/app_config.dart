import 'package:flutter/foundation.dart'
    show kIsWeb, kReleaseMode, TargetPlatform, defaultTargetPlatform;

/// Global API configuration for the OWP shared backend.
///
/// Routing strategy:
///   • Web (Chrome dev)     → http://localhost:5131/api
///   • Android Physical     → http://192.168.1.6:5131/api (Host LAN IP)
///   • Android Emulator     → http://10.0.2.2:5131/api (when --dart-define=USE_EMULATOR=true)
///   • Android USB Reverse  → http://127.0.0.1:5131/api (when --dart-define=USE_ADB_REVERSE=true)
///   • Production (Release) → [productionBaseUrl]
class AppConfig {
  AppConfig._();

  /// Host machine IPv4 address for physical Android device testing over Wi-Fi.
  /// Overridable at run time via `--dart-define=DEV_IP=<ip>`.
  static const String devHostIp = String.fromEnvironment(
    'DEV_IP',
    defaultValue: '10.36.249.167',
  );

  /// Backend port (ASP.NET Core Web API).
  /// Overridable at run time via `--dart-define=PORT=<port>`.
  static const String backendPort = String.fromEnvironment(
    'PORT',
    defaultValue: '5131',
  );

  /// The live / staging backend URL (used in release builds).
  static const String _productionBaseUrl = 'https://api.oleena.lk';

  /// Returns the correct base URL for the current run environment.
  static String get baseUrl {
    if (kIsWeb) {
      // Running on Chrome / Web – the .NET API is on the same machine.
      return 'http://localhost:$backendPort/api';
    }

    if (kReleaseMode) {
      return '$_productionBaseUrl/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // If running specifically on the Android Emulator, allow loopback alias
      const bool useEmulator = bool.fromEnvironment(
        'USE_EMULATOR',
        defaultValue: false,
      );
      if (useEmulator) {
        return 'http://10.0.2.2:$backendPort/api';
      }

      // If using `adb reverse tcp:5131 tcp:5131` over USB cable
      const bool useAdbReverse = bool.fromEnvironment(
        'USE_ADB_REVERSE',
        defaultValue: false,
      );
      if (useAdbReverse) {
        return 'http://127.0.0.1:$backendPort/api';
      }

      // Physical Android phone connected to host machine on the same Wi-Fi LAN
      return 'http://$devHostIp:$backendPort/api';
    }

    // iOS Simulator or desktop device in debug mode
    return 'http://$devHostIp:$backendPort/api';
  }

  // ── Shared-preferences & storage keys ──────────────────────────────────────
  static const String kHasSeenOnboarding = 'hasSeenOnboarding';
  static const String kAuthToken = 'auth_token';
}
