import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/localization/app_strings.dart';
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
      height: 80,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: ext.border?.withValues(alpha: 0.3) ?? Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _auraItem(0, font, theme, ext),
              _chatItem(1, font, theme, ext),
              _sinePlayItem(2, font, theme, ext),
              _alertsItem(3, font, theme, ext),
              _profileItem(4, font, theme, ext),
            ],
          ),
        ),
      ),
    );
  }

  Widget _auraItem(int index, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : ext.textSecondary?.withValues(alpha: 0.3),
                boxShadow: isSelected ? [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1),
                ] : null,
              ),
              child: ClipOval(
                child: Image.asset('assets/images/aura_avatar_3d_v2.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected) Text('Aura', style: GoogleFonts.getFont(font, fontSize: 9, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _chatItem(int index, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_rounded,
              color: isSelected ? theme.colorScheme.primary : ext.textSecondary?.withValues(alpha: 0.4),
              size: 24,
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected) Text('Chat', style: GoogleFonts.getFont(font, fontSize: 9, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _sinePlayItem(int index, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSelected ? 58 : 54,
              height: isSelected ? 58 : 54,
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: isSelected ? 4 : 2,
                  ),
                  BoxShadow(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.sports_esports_rounded,
                    color: Colors.white,
                    size: isSelected ? 28 : 26,
                  ),
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
                          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.8), blurRadius: 4)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected) 
              Text('SINE Play', style: GoogleFonts.getFont(font, fontSize: 9, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _alertsItem(int index, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: isSelected ? theme.colorScheme.primary : ext.textSecondary?.withValues(alpha: 0.4),
              size: 24,
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected) Text('Alerts', style: GoogleFonts.getFont(font, fontSize: 9, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(int index, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_rounded,
              color: isSelected ? theme.colorScheme.primary : ext.textSecondary?.withValues(alpha: 0.4),
              size: 24,
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected) Text('Profile', style: GoogleFonts.getFont(font, fontSize: 9, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}