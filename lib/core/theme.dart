import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide design system and theme tokens for Oleena Wedding Planner.
class OleenaTheme {
  // Brand colors per design guidelines
  static const Color primary = Color(0xFF8E406F); // Mauve
  static const Color primaryHover = Color(0xFF75325A); // Hover / pressed
  static const Color primaryTint = Color(0xFFFDF0F4); // Light tint
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color backgroundSecondary = Color(0xFFF9FAFB); // Off-white
  static const Color textDark = Color(0xFF1F1F2E);
  static const Color textMuted = Color(0xFF8A8A9A);
  static const Color borderSubtle = Color(0xFFE8E8EE);

  // Spacing, Radius & Shadow tokens
  static const double radiusCard = 20.0;
  static const double radiusButton = 28.0;
  static const double radiusField = 14.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(radiusCard);
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(radiusButton);
  static final BorderRadius fieldBorderRadius = BorderRadius.circular(radiusField);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1F1F2E).withValues(alpha: 0.06),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.25),
          blurRadius: 18,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ];

  // Two-font system:
  // 1. Serif display face (Playfair Display) for headlines and titles
  static TextStyle get display => GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.25,
      );

  static TextStyle get brandTitle => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      );

  // 2. Sans-serif (Poppins) for body, labels, buttons, and eyebrows
  static TextStyle get eyebrow => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 2.2,
      );

  static TextStyle get headline => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textDark,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textMuted,
        height: 1.4,
      );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundSecondary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryHover,
        surface: background,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineMedium: headline,
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.poppins(
          color: textDark,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
