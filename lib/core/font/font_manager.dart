import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FontManager extends ChangeNotifier {
  static const _key = 'selected_font';
  String _fontFamily = 'Nunito'; // safe default
  String get fontFamily => _fontFamily;

  // 25 Best BOLD Fonts
  static const List<String> boldFonts = [
    'Anton', 'Alfa Slab One', 'Archivo Black', 'Bowlby One SC', 'Black Ops One', 
    'Chivo', 'Fjalla One', 'Fredoka One', 'Kanit', 'Montserrat', 
    'Oswald', 'Passion One', 'Paytone One', 'Righteous', 'Russo One', 
    'Secular One', 'Staatliches', 'Titan One', 'Ultra', 'Ubuntu', 
    'Bungee', 'Faster One', 'Luckiest Guy', 'Sigmar One', 'Yeseva One'
  ];

  // 25 Best MODERN / Apple Style Fonts
  static const List<String> otherFonts = [
    'Inter', 'Nunito', 'Outfit', 'Plus Jakarta Sans', 'Onest', 
    'Lexend', 'DM Sans', 'Public Sans', 'Urbanist', 'Work Sans', 
    'Epilogue', 'Sora', 'Be Vietnam Pro', 'Jost', 'Manrope', 
    'Figtree', 'Geologica', 'Instrument Sans', 'Rethink Sans', 'Schibsted Grotesque', 
    'Space Grotesque', 'Albert Sans', 'Barlow', 'Grop', 'Poppins'
  ];

  FontManager() {
    loadSavedFont();
  }

  Future<void> loadSavedFont() async {
    final prefs = await SharedPreferences.getInstance();
    _fontFamily = prefs.getString(_key) ?? 'Nunito';
    notifyListeners();
  }

  Future<void> setFont(String fontFamily) async {
    try {
      GoogleFonts.getFont(fontFamily);
      _fontFamily = fontFamily;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, fontFamily);
      notifyListeners();
    } catch (e) {
      debugPrint('Font not found: $fontFamily');
    }
  }

  TextTheme getTextTheme() {
    try {
      return GoogleFonts.getTextTheme(_fontFamily);
    } catch (e) {
      return GoogleFonts.nunitoTextTheme();
    }
  }

  static List<String> getAllFonts() => [...boldFonts, ...otherFonts];
}
