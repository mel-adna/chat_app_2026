import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF); // Modern Violet
  static const Color secondary = Color(0xFF03DAC6); // Teal Accent
  static const Color background = Color(0xFF121212); // Deep Dark
  static const Color surface = Color(0xFF1E1E1E); // Card Background
  static const Color error = Color(0xFFCF6679);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);

  static const Color googleButton = Color(0xFFDB4437);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
