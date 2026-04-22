import 'package:flutter/material.dart';

/// Senior-friendly theme: large fonts, high contrast, big touch targets.
/// Supports both light and dark mode with a metallic forest-green accent.
class AppTheme {
  AppTheme._();

  // Core brand colours — forest green palette
  static const Color brandGreen = Color(0xFF0a3d0f);        // very dark forest green (primary)
  static const Color brandGreenLight = Color(0xFF1B5E20);   // deep forest green
  static const Color brandGreenSurface = Color(0xFF052008); // near-black green
  static const Color accentOrange = Color(0xFFFF8F00);      // amber accent (unchanged)

  // Keep old names as aliases so no call-sites break
  static const Color brandBlue = brandGreen;
  static const Color brandBlueLight = brandGreenLight;
  static const Color brandBlueSurface = brandGreenSurface;

  // ─── Light Theme ───────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: brandBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFC8E6C9), // light green tint
        secondary: accentOrange,
        onSecondary: Colors.black,
        error: Color(0xFFC62828),
        surface: Colors.white,
        onSurface: Color(0xFF1A1A2E),
        surfaceContainerHighest: Color(0xFFF0F5F0), // faint green tint
      ),
      scaffoldBackgroundColor: const Color(0xFFF5FAF5), // faint green tint
      textTheme: _textTheme(const Color(0xFF1A1A2E), const Color(0xFF4A4A6A)),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(brandBlue),
      outlinedButtonTheme: _outlinedButtonTheme(brandBlue),
      textButtonTheme: _textButtonTheme(brandBlue),
      inputDecorationTheme: _inputDecorationTheme(brandBlue),
      cardTheme: _cardTheme(),
      dialogTheme: _dialogTheme(const Color(0xFF1A1A2E)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        extendedTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF69F0AE),               // mint green
        onPrimary: Colors.black,
        primaryContainer: Color(0xFF0a3d0f),       // very dark green — selected tile bg in dark mode
        secondary: accentOrange,
        onSecondary: Colors.black,
        error: Color(0xFFEF5350),
        surface: Color(0xFF0d1a0e),               // near-black green surface
        onSurface: Color(0xFFE8F5E9),             // soft green-white
        surfaceContainerHigh: Color(0xFF1A2F1B),  // dark green — search dropdown bg
        surfaceContainerHighest: Color(0xFF162918), // very dark green card
        outlineVariant: Color(0xFF2E5E2E),         // subtle green divider
      ),
      scaffoldBackgroundColor: const Color(0xFF080f09), // deep black-green
      textTheme: _textTheme(const Color(0xFFE8F5E9), const Color(0xFFA5D6A7)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0a3d0f),  // very dark forest green
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(brandBlueLight),   // #388E3C
      outlinedButtonTheme: _outlinedButtonTheme(const Color(0xFF69F0AE)),
      textButtonTheme: _textButtonTheme(const Color(0xFF69F0AE)),
      inputDecorationTheme: _inputDecorationThemeDark(),
      cardTheme: _cardThemeDark(),
      dialogTheme: _dialogTheme(const Color(0xFFE8E8F0)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1B5E20), // deep forest green — prominent but not neon
        foregroundColor: Colors.white,
        extendedTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Shared components ─────────────────────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primary),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: TextStyle(fontSize: 18, color: primary),
      bodyMedium: TextStyle(fontSize: 16, color: secondary),
      labelLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color bg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(Color color) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(double.infinity, 64),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: color, width: 2),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color color) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color focusColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 18, color: Color(0xFF757575)),
      hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF9E9E9E)),
    );
  }

  static InputDecorationTheme _inputDecorationThemeDark() {
    return InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF162918), // very dark green card fill
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E5E2E), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E5E2E), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF69F0AE), width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 18, color: Color(0xFFA5D6A7)),
      hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF4A7A4A)),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(8),
    );
  }

  static CardThemeData _cardThemeDark() {
    return CardThemeData(
      elevation: 3,
      color: const Color(0xFF0d1a0e), // near-black green card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(8),
    );
  }

  static DialogThemeData _dialogTheme(Color textColor) {
    return DialogThemeData(
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
      contentTextStyle: TextStyle(fontSize: 18, color: textColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
