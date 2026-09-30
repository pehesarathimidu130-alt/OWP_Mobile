import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'core/app_router.dart';
import 'core/auth_provider.dart';
import 'core/favorites_provider.dart';
import 'core/theme.dart';
import 'features/profile/providers/customer_profile_provider.dart';
import 'features/profile/providers/notification_preferences_provider.dart';

import 'core/session_events.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Asynchronously discover host IP or connect via ADB reverse / cached IP
  try {
    await AppConfig.initialize().timeout(
      const Duration(milliseconds: 1500),
      onTimeout: () => debugPrint('[AppConfig] Init timed out; using defaults'),
    );
  } catch (e) {
    debugPrint('[AppConfig] Init error: $e');
  }

  runApp(const OleenaApp());
}

class OleenaApp extends StatefulWidget {
  const OleenaApp({super.key});

  @override
  State<OleenaApp> createState() => _OleenaAppState();
}

class _OleenaAppState extends State<OleenaApp> {
  late final AuthProvider _authProvider;
  late final FavoritesProvider _favoritesProvider;
  late final CustomerProfileProvider _customerProfileProvider;
  late final NotificationPreferencesProvider _notificationPreferencesProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _favoritesProvider = FavoritesProvider();
    _customerProfileProvider = CustomerProfileProvider();
    _notificationPreferencesProvider = NotificationPreferencesProvider();

    // Register single root callback for 401 Unauthorized session expiration
    SessionEvents.onUnauthorized = () async {
      await _authProvider.logout();
      _favoritesProvider.clear();
      _customerProfileProvider.clear();
      appRouter.go('/login');
    };
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _favoritesProvider.dispose();
    _customerProfileProvider.dispose();
    _notificationPreferencesProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _favoritesProvider),
        ChangeNotifierProvider.value(value: _customerProfileProvider),
        ChangeNotifierProvider.value(value: _notificationPreferencesProvider),
      ],
      child: MaterialApp.router(
        title: 'Oleena Wedding Planner',
        debugShowCheckedModeBanner: false,
        theme: OleenaTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}

