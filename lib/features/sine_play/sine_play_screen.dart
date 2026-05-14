import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

class SinePlayScreen extends ConsumerWidget {
  const SinePlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, font),
            Expanded(
              child: _buildContent(theme, ext, font),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String font) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.sports_esports_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SINE PLAY',
                  style: GoogleFonts.getFont(font, 
                    fontSize: 18, 
                    fontWeight: FontWeight.w800, 
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upcoming Games 🔥',
                  style: GoogleFonts.getFont('Inter',
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppThemeExtension ext, String font) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComingSoonBadge(theme, font),
          const SizedBox(height: 24),
          Text(
            'Games Coming Soon',
            style: GoogleFonts.getFont(font, 
              fontSize: 20, 
              fontWeight: FontWeight.w700, 
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildGamePreview(
            theme, ext, font,
            '🏎️ Racing Game',
            'High speed racing experience',
            Icons.directions_car_rounded,
          ),
          _buildGamePreview(
            theme, ext, font,
            '⚡ Trishul Runner',
            'Fast paced endless runner',
            Icons.flash_on_rounded,
          ),
          _buildGamePreview(
            theme, ext, font,
            '🎲 Ludo Classic',
            'Play with friends online',
            Icons.casino_rounded,
          ),
          _buildGamePreview(
            theme, ext, font,
            '👻 Horror Adventure',
            'Scary survival experience',
            Icons.dark_mode_rounded,
          ),
          _buildGamePreview(
            theme, ext, font,
            '🕹️ Arcade Classics',
            'Retro gaming collection',
            Icons.sports_esports_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonBadge(ThemeData theme, String font) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Upcoming Update 🎮',
            style: GoogleFonts.getFont(font, 
              fontSize: 13, 
              fontWeight: FontWeight.w600, 
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePreview(ThemeData theme, AppThemeExtension ext, String font, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.border?.withValues(alpha: 0.3) ?? Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.getFont(font, 
                    fontSize: 15, 
                    fontWeight: FontWeight.w600, 
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.getFont(font, 
                    fontSize: 12, 
                    color: ext.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: ext.textSecondary?.withValues(alpha: 0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}