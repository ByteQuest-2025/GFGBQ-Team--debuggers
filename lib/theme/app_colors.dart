import 'package:flutter/material.dart';

/// App-wide color constants - Trust-building green theme for investment app
class AppColors {
  // Primary Colors - Trust-evoking green
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  
  // Accent - Call-to-action orange
  static const Color accent = Color(0xFFFF6F00);
  static const Color accentLight = Color(0xFFFF9E40);
  
  // Background Colors
  static const Color warmWhite = Color(0xFFFFFBF5);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  
  // Neutral Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color disabled = Color(0xFFE0E0E0);
  
  // Risk Level Colors
  static const Color riskVeryLow = Color(0xFF4CAF50);
  static const Color riskLow = Color(0xFF8BC34A);
  static const Color riskModerate = Color(0xFFFF9800);
  static const Color riskHigh = Color(0xFFFF5722);
  
  // Investment Pack Colors
  static const Color chaiPack = Color(0xFFD7CCC8);
  static const Color thaliPack = Color(0xFFFFE0B2);
  static const Color moviePack = Color(0xFFE1BEE7);
  static const Color festivalPack = Color(0xFFFFCDD2);
  
  // Badge Colors
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Private constructor
  AppColors._();
}
