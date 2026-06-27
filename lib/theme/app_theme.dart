import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primaryBlue = Color(0xFF0E4DA4);
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color accentCyan = Color(0xFF00B4D8);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color errorRed = Color(0xFFC62828);
  static const Color warningAmber = Color(0xFFF57F17);
  static const Color neutralGrey = Color(0xFF546E7A);

  // Answer state colors (Light Mode)
  static const Color correctBg = Color(0xFFE8F5E9);
  static const Color correctBorder = Color(0xFF4CAF50);
  static const Color wrongBg = Color(0xFFFFEBEE);
  static const Color wrongBorder = Color(0xFFEF5350);
  static const Color neutralBg = Color(0xFFF0F4FF);
  static const Color neutralBorder = Color(0xFFBBD0FF);

  // Answer state colors (Dark Mode)
  static const Color darkCorrectBg = Color(0xFF1B382B);
  static const Color darkCorrectBorder = Color(0xFF4CAF50);
  static const Color darkWrongBg = Color(0xFF4A1E24);
  static const Color darkWrongBorder = Color(0xFFEF5350);
  static const Color darkNeutralBg = Color(0xFF1E293B);
  static const Color darkNeutralBorder = Color(0xFF475569);

  static ThemeData get lightTheme {
    const seedColor = primaryBlue;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: accentCyan,
      ),
      fontFamily: 'Nunito',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFFF5F7FF),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE8EDF8), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: neutralBg,
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryBlue,
        ),
        side: const BorderSide(color: neutralBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0D1B2A),
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0D1B2A),
        ),
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1B2A),
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1B2A),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1B2A),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0D1B2A),
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF2C3E50),
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF546E7A),
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF546E7A),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EDF8),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    const seedColor = Color(0xFF6366F1); // Indigo seed

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF06B6D4),
        surface: const Color(0xFF0F172A),
      ),
      fontFamily: 'Nunito',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF0B0F19),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF151F32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1),
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF818CF8),
        ),
        side: const BorderSide(color: Color(0xFF334155)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCBD5E1),
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8),
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E293B),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
