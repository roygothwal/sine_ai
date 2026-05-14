import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- THEME PROVIDER ---
final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super('original_sine_purple') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selected_theme_id') ?? 'original_sine_purple';
  }

  Future<void> setTheme(String id) async {
    state = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme_id', id);
  }
}

// --- FONT PROVIDER ---
final fontProvider = StateNotifierProvider<FontNotifier, String>((ref) {
  return FontNotifier();
});

class FontNotifier extends StateNotifier<String> {
  FontNotifier() : super('Outfit') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selected_font_family') ?? 'Outfit';
  }

  Future<void> setFont(String family) async {
    state = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_font_family', family);
  }
}

// --- LANGUAGE PROVIDER ---
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('english') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'english';
    state = lang;
    AppStrings.currentLanguage = lang;
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    AppStrings.currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}

// --- USER PROVIDER ---
final userProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// --- ALARM PROVIDER ---
final alarmProvider = StateNotifierProvider<AlarmNotifier, List<Map<String, dynamic>>>((ref) {
  return AlarmNotifier();
});

class AlarmNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  AlarmNotifier() : super([
    {
      'time': '06:00',
      'label': '🏋️ Gym Time!',
      'message': 'Tune bola tha gym jayega... uth bhai!',
      'days': [true, true, false, true, true, false, false],
      'active': true,
      'mood': 'Motivational 🔥',
      'id': 1,
    },
    {
      'time': '22:00',
      'label': '😴 So Ja!',
      'message': 'Phone rakh so ja. Kal bhi ana hai',
      'days': [true, true, true, true, true, true, true],
      'active': true,
      'mood': 'Gentle 🌙',
      'id': 2,
    },
  ]);

  void addAlarm(Map<String, dynamic> alarm) => state = [...state, alarm];
  void removeAlarm(int index) => state = [...state]..removeAt(index);
  void toggleAlarm(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) {...state[i], 'active': !state[i]['active']} else state[i]
    ];
  }
  void updateAlarm(int index, Map<String, dynamic> alarm) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) alarm else state[i]
    ];
  }
}

// --- REMINDER PROVIDER ---
final reminderProvider = StateNotifierProvider<ReminderNotifier, List<Map<String, dynamic>>>((ref) {
  return ReminderNotifier();
});

class ReminderNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ReminderNotifier() : super([
    {
      'time': '09:00',
      'label': '💧 Paani Piyo',
      'message': 'Bhai paani pi le — health is wealth!',
      'repeat': 'Daily',
      'active': true,
      'icon': '💧',
      'id': 101,
    },
    {
      'time': '13:00',
      'label': '🍱 Khana Khao',
      'message': 'Lunch time ho gaya — kha le yaar!',
      'repeat': 'Weekdays',
      'active': true,
      'icon': '🍱',
      'id': 102,
    },
  ]);

  void addReminder(Map<String, dynamic> r) => state = [...state, r];
  void removeReminder(int index) => state = [...state]..removeAt(index);
  void toggleReminder(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) {...state[i], 'active': !state[i]['active']} else state[i]
    ];
  }
  void updateReminder(int index, Map<String, dynamic> r) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) r else state[i]
    ];
  }
}
