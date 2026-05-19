import 'package:flutter/material.dart';

/// Korean Ins-style Morandi color system
class AppColors {
  AppColors._();

  // Primary palette
  static const Color background = Color(0xFFFAF7F5);
  static const Color cardBackground = Color(0xFFF5F0EC);
  static const Color primary = Color(0xFFC4A89A);
  static const Color primaryLight = Color(0xFFD4C5BE);
  static const Color accent1 = Color(0xFFA3B5C8);
  static const Color accent2 = Color(0xFFD4C5BE);

  // Text
  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color textHint = Color(0xFFC0C0C0);

  // Semantic
  static const Color coral = Color(0xFFE8C4B8);
  static const Color success = Color(0xFFB5C9B7);
  static const Color warning = Color(0xFFE8D4B8);

  // Mood colors
  static const Color moodHappy = Color(0xFFFFD5B8);
  static const Color moodCalm = Color(0xFFB8D4D4);
  static const Color moodSad = Color(0xFFB8C4D4);
  static const Color moodAnxious = Color(0xFFD4C4D8);
  static const Color moodAngry = Color(0xFFE8C4C4);

  // Glass effect
  static const Color glassOverlay = Color(0xB3FFFFFF); // white 0.7 alpha
  static const Color glassBorder = Color(0x4DFFFFFF); // white 0.3 alpha
  static const Color glassShadow = Color(0x26C4A89A); // primary 0.15 alpha
}
