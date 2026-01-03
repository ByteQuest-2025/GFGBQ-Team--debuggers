import 'package:flutter/material.dart';

class AppTheme {
  // Minimal Color Palette - Warm White and Black
  static const Color warmWhite = Color(0xFFFFFBF5); // Warm white background
  static const Color pureBlack = Color(0xFF000000); // Pure black text
  static const Color blackSecondary = Color(0xFF1A1A1A); // Slightly softer black
  static const Color dividerColor = Color(0xFFE5E5E5); // Very subtle divider

  // Minimal Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false, // Use Material 2 for flatter design
      brightness: Brightness.light,
      
      // Color Scheme - Minimal black and white
      colorScheme: ColorScheme.light(
        primary: pureBlack,
        secondary: pureBlack,
        surface: warmWhite,
        background: warmWhite,
        error: pureBlack,
        onPrimary: warmWhite,
        onSecondary: warmWhite,
        onSurface: pureBlack,
        onBackground: pureBlack,
        onError: warmWhite,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: warmWhite,
      
      // App Bar Theme - Minimal, no elevation
      appBarTheme: const AppBarTheme(
        backgroundColor: warmWhite,
        foregroundColor: pureBlack,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: pureBlack,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(
          color: pureBlack,
          size: 22,
        ),
      ),
      
      // Card Theme - Flat, no elevation
      cardTheme: CardThemeData(
        color: warmWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Button Themes - Minimal, flat design
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pureBlack,
          foregroundColor: warmWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pureBlack,
          side: const BorderSide(color: pureBlack, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: pureBlack,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      
      // Floating Action Button Theme - Minimal
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: pureBlack,
        foregroundColor: warmWhite,
        elevation: 0,
      ),
      
      // Input Decoration Theme - Minimal borders
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: pureBlack, width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: pureBlack, width: 1),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: pureBlack, width: 1),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: pureBlack, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        hintStyle: const TextStyle(color: blackSecondary),
      ),
      
      // Text Theme - Simple, minimal typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: pureBlack,
          letterSpacing: 0,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: pureBlack,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: pureBlack,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: pureBlack,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: blackSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: pureBlack,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: blackSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: blackSecondary,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: pureBlack,
        size: 20,
      ),
      
      // Divider Theme - Minimal
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 0,
      ),
      
      // Chip Theme - Flat design
      chipTheme: ChipThemeData(
        backgroundColor: warmWhite,
        selectedColor: pureBlack,
        labelStyle: const TextStyle(color: pureBlack),
        secondaryLabelStyle: const TextStyle(color: warmWhite),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        elevation: 0,
      ),
      
      // Bottom Navigation Bar Theme - Minimal
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: warmWhite,
        selectedItemColor: pureBlack,
        unselectedItemColor: blackSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w300,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

