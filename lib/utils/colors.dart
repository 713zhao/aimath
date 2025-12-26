import 'package:flutter/material.dart';

/// Color palette for the Math Practice App
/// All colors follow the design specification
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color accentGold = Color(0xFFFFB81C);

  // Neutral colors
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);

  // Background colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color darkBackground = Color(0xFF121212);

  // Feedback colors
  static const Color positiveGreen = Color(0xFFE8F5E9);
  static const Color negativeRed = Color(0xFFFFEBEE);
  static const Color infoBg = Color(0xFFE3F2FD);

  // Gradient colors (for future use)
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF45A049),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFE53935),
  ];

  // Opacity colors
  static Color primaryBlueWithOpacity(double opacity) =>
      primaryBlue.withValues(alpha: opacity);
  
  static Color successGreenWithOpacity(double opacity) =>
      successGreen.withValues(alpha: opacity);
  
  static Color errorRedWithOpacity(double opacity) =>
      errorRed.withValues(alpha: opacity);
}
