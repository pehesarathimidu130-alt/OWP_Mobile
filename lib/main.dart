import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';

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
    return MaterialApp(
      title: 'Oleena Wedding Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE94B73),
          brightness: Brightness.light,
          primary: const Color(0xFFE94B73),
          secondary: const Color(0xFFFFB3C6),
          surface: Colors.white,
          onPrimary: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: const Color(0xFF1F1F2E)),
          headlineMedium: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F2E)),
          bodyLarge: GoogleFonts.poppins(
              fontSize: 16, color: const Color(0xFF1F1F2E)),
          bodyMedium: GoogleFonts.poppins(
              fontSize: 14, color: const Color(0xFF8A8A9A)),
          labelLarge: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1F1F2E)),
          titleTextStyle: GoogleFonts.poppins(
            color: const Color(0xFF1F1F2E),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94B73),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
            textStyle: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFE94B73),
          unselectedItemColor: Color(0xFFBBBBCC),
          type: BottomNavigationBarType.fixed,
          elevation: 12,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomeScreen(),
    );
  }
}
