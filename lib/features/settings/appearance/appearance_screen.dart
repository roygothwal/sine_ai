import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/themes/premium_themes.dart';
import 'package:sine_ai/core/font/font_manager.dart';

class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final font = ref.watch(fontProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance', style: GoogleFonts.getFont(font, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Themes'), Tab(text: 'Fonts')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ThemesGrid(),
          _FontsSection(searchCtrl: _searchCtrl, searchQuery: _searchQuery),
        ],
      ),
    );
  }
}

class _FontsSection extends ConsumerStatefulWidget {
  final TextEditingController searchCtrl;
  final String searchQuery;
  const _FontsSection({required this.searchCtrl, required this.searchQuery});

  @override
  ConsumerState<_FontsSection> createState() => _FontsSectionState();
}

class _FontsSectionState extends ConsumerState<_FontsSection> {
  String _activeCategory = "Bold";

  @override
  Widget build(BuildContext context) {
    final List<String> currentList = _activeCategory == "Bold" 
        ? FontManager.boldFonts 
        : FontManager.otherFonts;

    final filteredFonts = currentList
        .where((f) => f.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    
    final theme = ref.watch(themeProvider);
    final isDark = !PremiumThemes.allThemes.firstWhere((t) => t.id == theme).isLight;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: widget.searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search fonts...', 
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _categoryChip("Bold"),
                  const SizedBox(width: 8),
                  _categoryChip("Others"),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredFonts.length,
            itemBuilder: (context, i) => _FontCard(fontName: filteredFonts[i]),
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(String label) {
    final isSelected = _activeCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _activeCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FontCard extends ConsumerWidget {
  final String fontName;
  const _FontCard({required this.fontName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFont = ref.watch(fontProvider);
    final isSelected = currentFont == fontName;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(fontProvider.notifier).setFont(fontName);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fontName,
                    style: _getSafeGoogleFont(fontName, fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Beyond Intelligence',
                    style: _getSafeGoogleFont(fontName, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected) 
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // Fallback to avoid red error if a font fails to load or doesn't exist
  TextStyle _getSafeGoogleFont(String name, {double? fontSize, FontWeight? fontWeight}) {
    try {
      return GoogleFonts.getFont(name, fontSize: fontSize, fontWeight: fontWeight);
    } catch (e) {
      return TextStyle(fontFamily: 'sans-serif', fontSize: fontSize, fontWeight: fontWeight);
    }
  }
}

class _ThemesGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeId = ref.watch(themeProvider);
    final themes = PremiumThemes.allThemes;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: themes.length,
      itemBuilder: (context, i) {
        final theme = themes[i];
        final isSelected = currentThemeId == theme.id;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(themeProvider.notifier).setTheme(theme.id);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? theme.primary : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2.5 : 1,
              ),
              gradient: theme.backgroundGradient,
            ),
            child: Stack(
              children: [
                if (theme.isPremium)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: const Icon(Icons.star, size: 12, color: Colors.white),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(theme.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 12),
                      Text(
                        theme.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: theme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _colorDot(theme.primary),
                          _colorDot(theme.secondary),
                          _colorDot(theme.accent),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    bottom: 8, right: 8,
                    child: Icon(Icons.check_circle, color: theme.primary, size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorDot(Color c) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: 12, height: 12,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
  );
}
