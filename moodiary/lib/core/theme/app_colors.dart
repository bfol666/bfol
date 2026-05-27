import 'package:flutter/material.dart';

/// OKLCH-based color system.
///
/// Scene: 10pm bedroom, warm lamplight, phone in hand, reflecting on the day.
/// Strategy: Committed — warm rose carries 30-40% of surface.
/// No pure black, no pure white. Every neutral is tinted toward the warm axis.
class AppColors {
  AppColors._();

  // ── Surfaces ──
  /// oklch(0.972 0.005 85) — warm off-white, main background
  static const Color background = Color(0xFFF8F5F2);

  /// oklch(0.988 0.003 85) — card / raised surface
  static const Color surface = Color(0xFFFDFBF9);

  /// oklch(0.94 0.006 85) — recessed / secondary panel
  static const Color surfaceMuted = Color(0xFFEFEBE7);

  // ── Primary accent (Committed: ~35% of surface) ──
  /// oklch(0.60 0.11 15) — warm rose, primary actions & selection
  static const Color primary = Color(0xFFC48E84);

  /// oklch(0.82 0.04 15) — muted rose, tags / chips
  static const Color primaryMuted = Color(0xFFE8D6D2);

  // ── Secondary accents ──
  /// oklch(0.58 0.06 240) — mist blue, links / secondary info
  static const Color accentBlue = Color(0xFF92A7B8);

  /// oklch(0.68 0.08 28) — coral, alerts / highlights
  static const Color coral = Color(0xFFD4A098);

  // ── Text ──
  /// oklch(0.28 0.005 270) — near-black, body text
  static const Color textPrimary = Color(0xFF3D3D40);

  /// oklch(0.52 0.005 270) — secondary text
  static const Color textSecondary = Color(0xFF7A7A7E);

  /// oklch(0.72 0.004 270) — hint / placeholder
  static const Color textHint = Color(0xFFB0B0B4);

  // ── Semantic ──
  /// oklch(0.68 0.08 150) — success green
  static const Color success = Color(0xFF8EB89C);

  /// oklch(0.72 0.08 75) — warning amber
  static const Color warning = Color(0xFFD4BE98);

  // ── Mood colors (used as subtle card tints & indicators) ──
  /// oklch(0.80 0.08 70) — happy
  static const Color moodHappy = Color(0xFFEED4A8);

  /// oklch(0.74 0.05 195) — calm
  static const Color moodCalm = Color(0xFFAEC8C4);

  /// oklch(0.68 0.04 250) — sad
  static const Color moodSad = Color(0xFFA4B4C8);

  /// oklch(0.72 0.05 305) — anxious
  static const Color moodAnxious = Color(0xFFC4B4CE);

  /// oklch(0.70 0.08 20) — angry
  static const Color moodAngry = Color(0xFFD4AEA8);

  /// oklch(0.78 0.06 50) — grateful
  static const Color moodGrateful = Color(0xFFE4CEAA);

  /// oklch(0.76 0.05 40) — excited
  static const Color moodExcited = Color(0xFFE2C4AE);

  // ── Glass (reserved for AI reply bubble only) ──
  static const Color glassOverlay = Color(0xB3FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
