import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_model.dart';
import 'premium_themes.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_theme_id';
  SineTheme _currentTheme = PremiumThemes.defaultTheme;

  SineTheme get currentTheme => _currentTheme;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString(_themeKey);
    if (themeId != null) {
      try {
        final theme = PremiumThemes.allThemes.firstWhere(
          (t) => t.id == themeId,
          orElse: () => PremiumThemes.defaultTheme,
        );
        _currentTheme = theme;
        notifyListeners();
      } catch (e) {
        _currentTheme = PremiumThemes.defaultTheme;
        notifyListeners();
      }
    }
  }

  Future<void> setTheme(String themeId) async {
    final theme = PremiumThemes.allThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => PremiumThemes.defaultTheme,
    );
    _currentTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
  }

  bool isThemePremium(String themeId) {
    try {
      return PremiumThemes.allThemes.firstWhere((t) => t.id == themeId).isPremium;
    } catch (_) {
      return false;
    }
  }
}
