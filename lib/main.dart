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

class OleenaApp extends StatelessWidget {
  const OleenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationPreferencesProvider()),
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
