import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_model.dart';
import 'theme_extensions.dart';

class AppTheme {
  static ThemeData createTheme(SineTheme model, String fontFamily) {
    final base = model.isLight ? ThemeData.light(useMaterial3: true) : ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      scaffoldBackgroundColor: model.background,
      canvasColor: model.background,
      cardColor: model.card,
      colorScheme: ColorScheme(
        brightness: model.isLight ? Brightness.light : Brightness.dark,
        primary: model.primary,
        onPrimary: model.buttonText,
        secondary: model.secondary,
        onSecondary: model.buttonText,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: model.surface,
        onSurface: model.text,
        outline: model.border,
      ),
      cardTheme: CardThemeData(
        color: model.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: model.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: model.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: model.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: model.background,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: model.border,
        thickness: 1,
        space: 1,
      ),
      textTheme: _getTextTheme(fontFamily, model.text, model.textSecondary, base.textTheme),
      iconTheme: IconThemeData(color: model.text, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: model.text),
        titleTextStyle: GoogleFonts.getFont(fontFamily, 
          fontSize: 20, 
          fontWeight: FontWeight.w800, 
          color: model.text,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: model.primary,
          foregroundColor: model.buttonText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.getFont(fontFamily, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: model.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: model.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: model.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: model.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.getFont(fontFamily, color: model.inputHint),
        prefixIconColor: model.primary,
        suffixIconColor: model.textSecondary.withValues(alpha: 0.5),
      ),
      extensions: [
        AppThemeExtension(
          surface: model.surface,
          card: model.card,
          border: model.border,
          accent: model.accent,
          textSecondary: model.textSecondary,
          inputFill: model.inputFill,
          inputHint: model.inputHint,
          buttonText: model.buttonText,
          selectedTab: model.selectedTab,
          unselectedTab: model.unselectedTab,
          chatBubbleUser: model.chatBubbleUser,
          chatBubbleAI: model.chatBubbleAI,
          navbarBg: model.navbarBg,
          glowColor: model.glowColor,
          primaryGradient: model.primaryGradient,
          backgroundGradient: model.backgroundGradient,
        ),
      ],
    );
  }

  static TextTheme _getTextTheme(String font, Color text, Color secondary, TextTheme base) {
    try {
      return GoogleFonts.getTextTheme(font, base).apply(
        bodyColor: text,
        displayColor: text,
      ).copyWith(
        displayLarge: GoogleFonts.getFont(font, color: text, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.getFont(font, color: text, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.getFont(font, color: text, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.getFont(font, color: text, fontSize: 16),
        bodyMedium: GoogleFonts.getFont(font, color: text, fontSize: 14),
        bodySmall: GoogleFonts.getFont(font, color: secondary, fontSize: 12),
        labelLarge: GoogleFonts.getFont(font, color: text, fontWeight: FontWeight.w600),
      );
    } catch (e) {
      return base.apply(
        bodyColor: text,
        displayColor: text,
      );
    }
  }
}
