import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

class BottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: ext.border?.withValues(alpha: 0.1) ?? Colors.transparent,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, 'Aura', Icons.auto_awesome_rounded, font, theme, ext),
            _navItem(1, 'Chat', Icons.chat_rounded, font, theme, ext),
            _centerItem(font, theme, ext),
            _navItem(3, 'Alerts', Icons.notifications_rounded, font, theme, ext),
            _navItem(4, 'Profile', Icons.settings_rounded, font, theme, ext),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, String label, IconData icon, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    
    if (index == 0) {
      return Expanded(
        child: GestureDetector(
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: isSelected ? 32 : 28,
                height: isSelected ? 32 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected 
                      ? LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  boxShadow: isSelected ? [
                    BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1),
                  ] : null,
                ),
                child: ClipOval(
                  child: Image.asset('assets/images/aura_avatar_3d_v2.png', fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(icon, color: Colors.white, size: 16),
                  ),
                ),
              ),
              if (isSelected) const SizedBox(height: 2),
              if (isSelected) Text(label, style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : null,
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : ext.textSecondary?.withValues(alpha: 0.35),
                size: isSelected ? 20 : 18,
              ),
            ),
            if (isSelected) const SizedBox(height: 2),
            if (isSelected) Text(label, style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _centerItem(String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == 2;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onTap(2),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.sports_esports_rounded, color: Colors.white, size: 24),
                if (!isSelected)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                        boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.8), blurRadius: 3)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isSelected) const SizedBox(height: 2),
        if (isSelected) Text('SINE Play', style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
      ],
    );
  }
}