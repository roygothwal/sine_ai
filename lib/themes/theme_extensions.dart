import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? surface;
  final Color? card;
  final Color? border;
  final Color? accent;
  final Color? textSecondary;
  final Color? inputFill;
  final Color? inputHint;
  final Color? buttonText;
  final Color? selectedTab;
  final Color? unselectedTab;
  final Color? chatBubbleUser;
  final Color? chatBubbleAI;
  final Color? navbarBg;
  final Color? glowColor;
  final LinearGradient? primaryGradient;
  final LinearGradient? backgroundGradient;

  const AppThemeExtension({
    required this.surface,
    required this.card,
    required this.border,
    required this.accent,
    required this.textSecondary,
    required this.inputFill,
    required this.inputHint,
    required this.buttonText,
    required this.selectedTab,
    required this.unselectedTab,
    required this.chatBubbleUser,
    required this.chatBubbleAI,
    required this.navbarBg,
    required this.glowColor,
    required this.primaryGradient,
    required this.backgroundGradient,
  });

  @override
  AppThemeExtension copyWith({
    Color? surface,
    Color? card,
    Color? border,
    Color? accent,
    Color? textSecondary,
    Color? inputFill,
    Color? inputHint,
    Color? buttonText,
    Color? selectedTab,
    Color? unselectedTab,
    Color? chatBubbleUser,
    Color? chatBubbleAI,
    Color? navbarBg,
    Color? glowColor,
    LinearGradient? primaryGradient,
    LinearGradient? backgroundGradient,
  }) {
    return AppThemeExtension(
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      textSecondary: textSecondary ?? this.textSecondary,
      inputFill: inputFill ?? this.inputFill,
      inputHint: inputHint ?? this.inputHint,
      buttonText: buttonText ?? this.buttonText,
      selectedTab: selectedTab ?? this.selectedTab,
      unselectedTab: unselectedTab ?? this.unselectedTab,
      chatBubbleUser: chatBubbleUser ?? this.chatBubbleUser,
      chatBubbleAI: chatBubbleAI ?? this.chatBubbleAI,
      navbarBg: navbarBg ?? this.navbarBg,
      glowColor: glowColor ?? this.glowColor,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      surface: Color.lerp(surface, other.surface, t),
      card: Color.lerp(card, other.card, t),
      border: Color.lerp(border, other.border, t),
      accent: Color.lerp(accent, other.accent, t),
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t),
      inputFill: Color.lerp(inputFill, other.inputFill, t),
      inputHint: Color.lerp(inputHint, other.inputHint, t),
      buttonText: Color.lerp(buttonText, other.buttonText, t),
      selectedTab: Color.lerp(selectedTab, other.selectedTab, t),
      unselectedTab: Color.lerp(unselectedTab, other.unselectedTab, t),
      chatBubbleUser: Color.lerp(chatBubbleUser, other.chatBubbleUser, t),
      chatBubbleAI: Color.lerp(chatBubbleAI, other.chatBubbleAI, t),
      navbarBg: Color.lerp(navbarBg, other.navbarBg, t),
      glowColor: Color.lerp(glowColor, other.glowColor, t),
      primaryGradient: t < 0.5 ? primaryGradient : other.primaryGradient,
      backgroundGradient: t < 0.5 ? backgroundGradient : other.backgroundGradient,
    );
  }
}
