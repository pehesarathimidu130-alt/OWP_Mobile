import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_config.dart';
import 'core/app_router.dart';
import 'core/auth_coordinator.dart';
import 'core/auth_provider.dart';
import 'core/favorites_provider.dart';
import 'core/notifications_provider.dart';
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
  late final NotificationsProvider _notificationsProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _favoritesProvider = FavoritesProvider();
    _customerProfileProvider = CustomerProfileProvider();
    _notificationPreferencesProvider = NotificationPreferencesProvider();
    _notificationsProvider = NotificationsProvider();

    bool isShowingExpiryDialog = false;

    // Register single root callback for 401 Unauthorized session expiration
    SessionEvents.onUnauthorized = () async {
      await _authProvider.logout();
      _favoritesProvider.clear();
      _customerProfileProvider.clear();
      _notificationsProvider.clear();
      appRouter.go('/home');

      if (isShowingExpiryDialog) return;
      isShowingExpiryDialog = true;

      final navContext = appRouter.routerDelegate.navigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        showDialog(
          context: navContext,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade800,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Session Expired',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: OleenaTheme.textDark,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your session has expired. Please log in again.',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: OleenaTheme.textMuted,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  isShowingExpiryDialog = false;
                },
                child: Text(
                  'Not now',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: OleenaTheme.textMuted,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  isShowingExpiryDialog = false;
                  AuthCoordinator.startFlow(navContext, isRegister: false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OleenaTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).then((_) {
          isShowingExpiryDialog = false;
        });
      } else {
        isShowingExpiryDialog = false;
      }
    };
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _favoritesProvider.dispose();
    _customerProfileProvider.dispose();
    _notificationPreferencesProvider.dispose();
    _notificationsProvider.dispose();
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
        ChangeNotifierProvider.value(value: _notificationsProvider),
      ],
      child: MaterialApp.router(
        title: 'Oleena Wedding Planner',
        debugShowCheckedModeBanner: false,
        theme: OleenaTheme.lightTheme,
        routerConfig: appRouter,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF9F6), // Ivory base
                  Color(0xFFFDF0F4), // Light blush
                  Color(0xFFF3D9E5), // Soft mauve/pink
                ],
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

