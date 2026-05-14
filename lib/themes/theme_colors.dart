import 'package:flutter/material.dart';

class ThemeColors {
  // Brand Core (Do NOT change)
  static const Color gold = Color(0xFFFFC107);
  static const Color orange = Color(0xFFFF8F00);
  
  // Professional Tones
  static const Color amoledBlack = Color(0xFF000000);
  static const Color matteBlack = Color(0xFF0F0F0F);
  static const Color obsidian = Color(0xFF1A1A1A);
  static const Color arcticWhite = Color(0xFFFFFFFF);
  static const Color ghostWhite = Color(0xFFF8F9FA);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Contrast Helpers
  static Color getContrastText(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  static Color getSecondaryText(Color background) {
    final base = getContrastText(background);
    return base.withValues(alpha: 0.65);
  }

  static Color getTertiaryText(Color background) {
    final base = getContrastText(background);
    return base.withValues(alpha: 0.35);
  }

  static Color getBorder(Color background) {
    return background.computeLuminance() > 0.5 
      ? Colors.black.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.12);
  }
}
