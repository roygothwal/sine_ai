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
      height: 72,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: ext.border ?? Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _auraItem(0, AppStrings.get('aura'), font, theme, ext),
            _chatItem(1, AppStrings.get('chats'), font, theme, ext),
            _alertsItem(2, AppStrings.get('alerts'), font, theme, ext),
            _profileItem(3, AppStrings.get('profile'), font, theme, ext),
          ],
        ),
      ),
    );
  }

  Widget _auraItem(int index, String label, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSelected ? 32 : 28,
              height: isSelected ? 32 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : ext.textSecondary?.withValues(alpha: 0.4),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/aura_avatar_3d_v2.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: isSelected ? 18 : 16,
                  ),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.getFont(font, 
                  fontSize: 10, 
                  fontWeight: FontWeight.w800, 
                  color: theme.colorScheme.primary,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _chatItem(int index, String label, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSelected ? 32 : 28,
              height: isSelected ? 32 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : ext.textSecondary?.withValues(alpha: 0.4),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/aura_avatar_3d.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: isSelected ? 18 : 16,
                  ),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.getFont(font, 
                  fontSize: 10, 
                  fontWeight: FontWeight.w800, 
                  color: theme.colorScheme.primary,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _alertsItem(int index, String label, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : ext.textSecondary?.withValues(alpha: 0.4),
              size: isSelected ? 26 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.getFont(font, 
                  fontSize: 10, 
                  fontWeight: FontWeight.w800, 
                  color: theme.colorScheme.primary,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _profileItem(int index, String label, String font, ThemeData theme, AppThemeExtension ext) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_rounded,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : ext.textSecondary?.withValues(alpha: 0.4),
              size: isSelected ? 26 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.getFont(font, 
                  fontSize: 10, 
                  fontWeight: FontWeight.w800, 
                  color: theme.colorScheme.primary,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}