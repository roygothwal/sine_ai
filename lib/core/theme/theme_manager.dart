import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme_data.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_theme_id';
  AppThemeData _currentTheme = AppThemeData.allThemes.first;

  AppThemeData get currentTheme => _currentTheme;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString(_themeKey);
    if (themeId != null) {
      final theme = AppThemeData.allThemes.firstWhere(
        (t) => t.id == themeId,
        orElse: () => AppThemeData.allThemes.first,
      );
      _currentTheme = theme;
      notifyListeners();
    }
  }

  void setTheme(String themeId) {
    final theme = AppThemeData.allThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => AppThemeData.allThemes.first,
    );
    _currentTheme = theme;
    notifyListeners();
    
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_themeKey, themeId);
    });
  }
}
