import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FontManager extends ChangeNotifier {
  static const String _fontKey = 'selected_font_family';
  String _currentFont = 'Outfit';

  String get currentFont => _currentFont;

  // --- MODERN (25) ---
  static const List<String> modernFonts = [
    'Outfit', 'Inter', 'Poppins', 'Nunito', 'DM Sans', 'Plus Jakarta Sans', 'Syne', 'Space Grotesk', 'Manrope', 'Urbanist', 'Figtree', 'Onest', 'Lexend', 'Satoshi', 'Quicksand', 'Work Sans', 'Karla', 'Public Sans', 'Sora', 'Jost', 'Red Hat Display', 'Varela Round', 'Figtree', 'Ubuntu', 'Questrial', 'Montserrat'
  ];

  // --- CLASSIC (20) ---
  static const List<String> classicFonts = [
    'Playfair Display', 'Merriweather', 'Lora', 'EB Garamond', 'Cormorant', 'Libre Baskerville', 'Crimson Text', 'Cardo', 'Spectral', 'Source Serif 4', 'Bitter', 'Vollkorn', 'Alegreya', 'Neuton', 'Arvo', 'Roboto Slab', 'Zilla Slab', 'Alice', 'Marcellus', 'Domine'
  ];

  // --- MONO/CODE (15) ---
  static const List<String> monoFonts = [
    'JetBrains Mono', 'Fira Code', 'Source Code Pro', 'IBM Plex Mono', 'Roboto Mono', 'Space Mono', 'Courier Prime', 'Inconsolata', 'Cutive Mono', 'Share Tech Mono', 'Anonymous Pro', 'VT323', 'Major Mono Display', 'Overpass Mono', 'DM Mono'
  ];

  // --- DISPLAY (20) ---
  static const List<String> displayFonts = [
    'Bebas Neue', 'Righteous', 'Bungee', 'Fredoka One', 'Titan One', 'Lilita One', 'Black Han Sans', 'Fugaz One', 'Staatliches', 'Anton', 'Oswald', 'Raleway', 'Montserrat', 'League Gothic', 'Barlow Condensed', 'Pathway Gothic One', 'Big Shoulders Display', 'Expletus Sans', 'Saira Condensed', 'Michroma'
  ];

  // --- FUN/CREATIVE (20) ---
  static const List<String> creativeFonts = [
    'Pacifico', 'Lobster', 'Dancing Script', 'Caveat', 'Kalam', 'Patrick Hand', 'Shadows Into Light', 'Permanent Marker', 'Rock Salt', 'Satisfy', 'Indie Flower', 'Gloria Hallelujah', 'Architects Daughter', 'Handlee', 'Courgette', 'Amatic SC', 'Covered By Your Grace', 'Sacramento', 'Great Vibes', 'Alex Brush'
  ];

  static List<String> getAllFonts() => [
    ...modernFonts,
    ...classicFonts,
    ...monoFonts,
    ...displayFonts,
    ...creativeFonts,
  ];

  static List<String> getFreeFonts() => getAllFonts().take(20).toList();

  static List<String> getPremiumFonts() => getAllFonts().skip(20).toList();

  FontManager() {
    loadSavedFont();
  }

  Future<String> loadSavedFont() async {
    final prefs = await SharedPreferences.getInstance();
    _currentFont = prefs.getString(_fontKey) ?? 'Outfit';
    notifyListeners();
    return _currentFont;
  }

  Future<void> setFont(String fontName) async {
    _currentFont = fontName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, fontName);
  }

  static TextTheme getTextTheme(String fontName) {
    try {
      // Robust check for font availability
      GoogleFonts.getFont(fontName);
      return GoogleFonts.getTextTheme(fontName);
    } catch (e) {
      return GoogleFonts.getTextTheme('Outfit');
    }
  }
}
