import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static const _key = 'app_language';
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LanguageManager() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  // Instant Switch - No Await
  void changeLanguage(String languageCode) {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    notifyListeners(); // UI immediately updates

    // Persistence happens in background
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_key, languageCode);
    });
  }
}
