import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show
        debugPrint,
        defaultTargetPlatform,
        kIsWeb,
        kReleaseMode,
        TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

/// Global API configuration for the OWP shared backend.
///
/// Routing strategy:
///   • Default (All platforms & environments) → https://owpbackend-production.up.railway.app/api
///   • Manual / Offline Local Dev            → Overridable via setHostIp() or `--dart-define=USE_LOCAL=true` / `--dart-define=DEV_IP=<ip>`
class AppConfig {
  AppConfig._();

  /// Live Railway deployment backend domain & URL
  static const String liveBackendDomain = 'owpbackend-production.up.railway.app';
  static const String liveBackendUrl = 'https://owpbackend-production.up.railway.app';
  static const String _defaultDevIp = '192.168.1.6';

  /// Web Client ID for Google Sign-In. The backend expects this as the Audience.
  /// Replace this placeholder with the actual Web Client ID.
  static const String googleWebClientId =
      '800917200874-0vua6g9bauoaqtr6t4ah7t96vlkmte38.apps.googleusercontent.com';

  // ── SharedPreferences & Storage Keys ─────────────────────────────────────────
  static const String kHasSeenOnboarding = 'hasSeenOnboarding';
  static const String kAuthToken = 'auth_token';
  static const String kCachedDevIp = 'cached_dev_host_ip';

  /// Dev switch to reset onboarding and session state on app launch (debug only).
  /// Activated with `--dart-define=FRESH_START=true`.
  static const bool freshStart = bool.fromEnvironment(
    'FRESH_START',
    defaultValue: false,
  );

  // ── Runtime Resolved State ──────────────────────────────────────────────────
  static String? _resolvedHost;
  static bool _isInitializing = false;

  /// Backend port (ASP.NET Core Web API).
  /// Overridable at run time via `--dart-define=PORT=<port>`.
  static String get backendPort {
    const fromEnv = String.fromEnvironment('PORT');
    if (fromEnv.isNotEmpty) return fromEnv;
    return '5131';
  }

  /// Host machine IPv4 address for physical mobile device testing.
  /// Overridable at run time via `--dart-define=DEV_IP=<ip>`.
  static String get devHostIp {
    if (_resolvedHost != null && _resolvedHost!.isNotEmpty) {
      return _resolvedHost!;
    }
    const fromEnv = String.fromEnvironment('DEV_IP');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _defaultDevIp;
  }

  /// Sets the host IP manually (e.g. from developer settings UI) and saves it.
  static Future<void> setHostIp(String ip) async {
    final cleanIp = ip.trim();
    if (cleanIp.isNotEmpty) {
      _resolvedHost = cleanIp;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kCachedDevIp, cleanIp);
      } catch (_) {}
    }
  }

  /// Returns the currently active backend host domain or IP.
  static String get currentHost => _resolvedHost ?? liveBackendDomain;

  /// Returns the correct base URL for the mobile application.
  /// Defaults to the live Railway backend (https://owpbackend-production.up.railway.app/api)
  /// instead of localhost or emulator loopback (10.0.2.2).
  static String get baseUrl {
    // 1. Explicit build-time override via --dart-define=BASE_URL=<url>
    const fromBaseUrl = String.fromEnvironment('BASE_URL');
    if (fromBaseUrl.isNotEmpty) {
      final trimmed = fromBaseUrl.trim();
      return trimmed.endsWith('/api') ? trimmed : '$trimmed/api';
    }

    // 2. Explicit local development requested via --dart-define=USE_LOCAL=true or DEV_IP
    const bool useLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: false);
    const fromDevIp = String.fromEnvironment('DEV_IP');

    if (useLocal || fromDevIp.isNotEmpty) {
      if (fromDevIp.isNotEmpty) {
        return 'http://$fromDevIp:$backendPort/api';
      }
      if (_resolvedHost != null && _resolvedHost!.isNotEmpty) {
        return 'http://$_resolvedHost:$backendPort/api';
      }
      const bool useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
      if (useEmulator) {
        return 'http://10.0.2.2:$backendPort/api';
      }
      return 'http://$devHostIp:$backendPort/api';
    }

    // 3. User manual runtime host override (e.g., from developer settings modal or tests)
    if (_resolvedHost != null && _resolvedHost!.isNotEmpty) {
      final h = _resolvedHost!.trim();
      if (h == liveBackendDomain || h.contains('railway.app')) {
        return '$liveBackendUrl/api';
      }
      if (h.startsWith('http://') || h.startsWith('https://')) {
        return h.endsWith('/api') ? h : '$h/api';
      }
      // If manually set to an IP address (e.g. 192.168.1.99 in unit tests or dev sheet)
      return 'http://$h:$backendPort/api';
    }

    // 4. Default: Live Railway backend URL
    return '$liveBackendUrl/api';
  }

  /// Initializes host configuration asynchronously.
  /// Points by default to the live Railway backend (https://owpbackend-production.up.railway.app/api).
  /// Only performs local subnet / emulator discovery if explicitly requested via USE_LOCAL=true or DEV_IP.
  static Future<void> initialize() async {
    if (kIsWeb || kReleaseMode || _isInitializing) return;
    _isInitializing = true;

    try {
      // Unless local dev is explicitly requested via --dart-define=USE_LOCAL=true or DEV_IP,
      // mobile app connects directly to the live Railway backend.
      const bool useLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: false);
      const fromDevIp = String.fromEnvironment('DEV_IP');

      if (!useLocal && fromDevIp.isEmpty) {
        debugPrint('[AppConfig] Connected to live Railway backend: $liveBackendUrl/api');
        return;
      }

      final port = int.tryParse(backendPort) ?? 5131;

      // 1. Check explicit compile-time flag
      if (fromDevIp.isNotEmpty) {
        _resolvedHost = fromDevIp;
        debugPrint('[AppConfig] Using build-time DEV_IP: $fromDevIp');
        return;
      }

      // 2. Check if ADB reverse (127.0.0.1) is active and reachable
      if (await _canConnect('127.0.0.1', port, timeoutMs: 200)) {
        _resolvedHost = '127.0.0.1';
        debugPrint('[AppConfig] Connected via ADB reverse (127.0.0.1:$port)');
        return;
      }

      // 3. Check if Android emulator loopback (10.0.2.2) is reachable
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (await _canConnect('10.0.2.2', port, timeoutMs: 200)) {
          _resolvedHost = '10.0.2.2';
          debugPrint(
            '[AppConfig] Connected via Android Emulator (10.0.2.2:$port)',
          );
          return;
        }
      }

      // 4. Check cached IP from SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(kCachedDevIp);
        if (cached != null && cached.isNotEmpty) {
          if (await _canConnect(cached, port, timeoutMs: 300)) {
            _resolvedHost = cached;
            debugPrint('[AppConfig] Connected via cached IP: $cached:$port');
            return;
          }
        }
      } catch (_) {}

      // 5. Quick probe default IP
      if (await _canConnect(_defaultDevIp, port, timeoutMs: 300)) {
        _resolvedHost = _defaultDevIp;
        debugPrint(
          '[AppConfig] Connected via default LAN IP: $_defaultDevIp:$port',
        );
        return;
      }

      // 6. Subnet auto-discovery
      final discovered = await autoDiscoverHost(timeoutMs: 400);
      if (discovered != null) {
        _resolvedHost = discovered;
        debugPrint('[AppConfig] Auto-discovered backend at: $discovered:$port');
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(kCachedDevIp, discovered);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[AppConfig] Initialization warning: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// Automatically discovers the backend host machine on the local Wi-Fi network
  /// by probing candidate IPs in parallel on the backend port.
  static Future<String?> autoDiscoverHost({int timeoutMs = 400}) async {
    if (kIsWeb || kReleaseMode) return null;

    try {
      final port = int.tryParse(backendPort) ?? 5131;

      // 1. Fast checks for loopback & emulator
      if (await _canConnect('127.0.0.1', port, timeoutMs: 200)) {
        return '127.0.0.1';
      }
      if (defaultTargetPlatform == TargetPlatform.android &&
          await _canConnect('10.0.2.2', port, timeoutMs: 200)) {
        return '10.0.2.2';
      }

      // 2. Discover local network interfaces on the mobile phone
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      final candidateIps = <String>{};

      // Add common fallbacks
      candidateIps.add(_defaultDevIp);

      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('127.') || ip.startsWith('169.254.')) continue;
          final parts = ip.split('.');
          if (parts.length != 4) continue;
          final prefix = '${parts[0]}.${parts[1]}.${parts[2]}.';
          final myOctet = int.tryParse(parts[3]) ?? 0;

          // Gateway and common developer host IPs first
          candidateIps.add('${prefix}1');
          candidateIps.add('${prefix}2');
          candidateIps.add('${prefix}3');
          candidateIps.add('${prefix}4');
          candidateIps.add('${prefix}5');
          candidateIps.add('${prefix}6');
          candidateIps.add('${prefix}7');
          candidateIps.add('${prefix}8');
          candidateIps.add('${prefix}9');
          candidateIps.add('${prefix}10');
          candidateIps.add('${prefix}100');
          candidateIps.add('${prefix}101');
          candidateIps.add('${prefix}102');
          candidateIps.add('${prefix}105');

          // Nearby IPs around the mobile device's DHCP lease
          for (int d = -5; d <= 5; d++) {
            final targetOctet = myOctet + d;
            if (targetOctet > 0 && targetOctet < 255) {
              candidateIps.add('$prefix$targetOctet');
            }
          }

          // Remaining subnet addresses (1..254)
          for (int i = 1; i <= 254; i++) {
            candidateIps.add('$prefix$i');
          }
        }
      }

      if (candidateIps.isEmpty) return null;

      // Probe candidates in fast parallel batches
      final candidateList = candidateIps.toList();

      // Batch 1: High priority candidates (first 30)
      final batch1 = candidateList.take(30).toList();
      final win1 = await _probeBatch(batch1, port, timeoutMs: timeoutMs);
      if (win1 != null) {
        _resolvedHost = win1;
        return win1;
      }

      // Batch 2: The rest of the subnet in chunks of 50
      final rest = candidateList.skip(30).toList();
      for (int i = 0; i < rest.length; i += 50) {
        final end = (i + 50 > rest.length) ? rest.length : i + 50;
        final chunk = rest.sublist(i, end);
        final win = await _probeBatch(chunk, port, timeoutMs: timeoutMs);
        if (win != null) {
          _resolvedHost = win;
          return win;
        }
      }
    } catch (e) {
      debugPrint('[AppConfig] Subnet scan failed: $e');
    }
    return null;
  }

  static Future<String?> _probeBatch(
    List<String> ips,
    int port, {
    required int timeoutMs,
  }) async {
    if (ips.isEmpty) return null;
    final completer = Completer<String?>();
    int pending = ips.length;

    for (final ip in ips) {
      _canConnect(ip, port, timeoutMs: timeoutMs)
          .then((ok) {
            if (ok && !completer.isCompleted) {
              completer.complete(ip);
            } else {
              pending--;
              if (pending == 0 && !completer.isCompleted) {
                completer.complete(null);
              }
            }
          })
          .catchError((_) {
            pending--;
            if (pending == 0 && !completer.isCompleted) {
              completer.complete(null);
            }
          });
    }

    return completer.future;
  }

  static Future<bool> _canConnect(
    String host,
    int port, {
    required int timeoutMs,
  }) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: Duration(milliseconds: timeoutMs),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}