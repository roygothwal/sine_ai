import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      height: 70,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: ext.border?.withValues(alpha: 0.2) ?? Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
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
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1),
                ] : null,
              ),
              child: ClipOval(
                child: Image.asset('assets/images/aura_avatar_3d_v2.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                ),
              ),
            ),
            if (isSelected) const SizedBox(height: 3),
            if (isSelected) Text('Aura', style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.chat_rounded,
                color: isSelected ? theme.colorScheme.primary : ext.textSecondary?.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
            if (isSelected) const SizedBox(height: 3),
            if (isSelected) Text('Chat', style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
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
                    blurRadius: 16,
                    spreadRadius: isSelected ? 3 : 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.sports_esports_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  if (!isSelected)
                    Positioned(
                      top: 3,
                      right: 3,
                      child: Container(
                        width: 7,
                        height: 7,
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
            if (isSelected) const SizedBox(height: 3),
            if (isSelected) 
              Text('SINE Play', style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: isSelected ? theme.colorScheme.primary : ext.textSecondary?.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
            if (isSelected) const SizedBox(height: 3),
            if (isSelected) Text('Alerts', style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_rounded,
                color: isSelected ? theme.colorScheme.primary : ext.textSecondary?.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
            if (isSelected) const SizedBox(height: 3),
            if (isSelected) Text('Profile', style: GoogleFonts.getFont(font, fontSize: 8, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}