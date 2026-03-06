import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassTrackTheme {
  static const Color primaryBlue = Color(0xFF3F68E4);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);
  static const Color subtleGray = Color(0xFFF0F0F0);
  static const Color errorRed = Color(0xFFD32F2F); // Standard error red
  static const Color successGreen = Color(0xFF388E3C); // Standard success green

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: backgroundWhite,
        onSurface: textDark,
        error: errorRed,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.lexendTextTheme().copyWith(
        displayLarge: GoogleFonts.lexend(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: GoogleFonts.lexend(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        labelLarge: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF10B981),
        surface: Color(0xFF1E293B),
        onSurface: Colors.white,
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172B),
      textTheme: GoogleFonts.lexendTextTheme()
          .apply(bodyColor: Colors.white, displayColor: Colors.white)
          .copyWith(
            displayLarge: GoogleFonts.lexend(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titleLarge: GoogleFonts.lexend(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyMedium: GoogleFonts.lexend(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
