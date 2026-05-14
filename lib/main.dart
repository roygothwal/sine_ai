import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/core/routing/app_routes.dart';
import 'package:sine_ai/themes/all_themes.dart';
import 'package:sine_ai/themes/premium_themes.dart';
import 'package:sine_ai/localization/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ProviderScope(
    child: SineAIApp(),
  ));
}

class SineAIApp extends ConsumerWidget {
  const SineAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeId = ref.watch(themeProvider);
    final fontName = ref.watch(fontProvider);
    
    // Watch language change and update the static string for AppStrings.get()
    final langKey = ref.watch(languageProvider);
    AppStrings.currentLanguage = langKey;
    final langLocale = AppStrings.getLocale(langKey);
    
    final theme = PremiumThemes.allThemes.firstWhere(
      (t) => t.id == themeId, 
      orElse: () => PremiumThemes.defaultTheme
    );

    return MaterialApp.router(
      title: 'SINE AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.createTheme(theme, fontName),
      routerConfig: appRouter,
      locale: langLocale,
    );
  }
}
