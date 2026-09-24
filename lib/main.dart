import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_router.dart';
import 'core/auth_provider.dart';
import 'core/favorites_provider.dart';
import 'core/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
