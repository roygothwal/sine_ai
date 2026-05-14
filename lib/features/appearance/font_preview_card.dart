import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/theme/app_theme_data.dart';
import 'package:sine_ai/core/providers/app_providers.dart';

class FontPreviewCard extends ConsumerWidget {
  final String fontName;
  final AppThemeData currentTheme;

  const FontPreviewCard({
    super.key,
    required this.fontName,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (context) {
        TextStyle? fontStyle;
        try {
          // Verify font exists
          fontStyle = GoogleFonts.getFont(
            fontName,
            fontSize: 16, // Reduced size to prevent overflow
            fontWeight: FontWeight.bold,
            color: currentTheme.textPrimary,
          );
        } catch (e) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            ref.read(fontProvider.notifier).setFont(fontName);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: currentTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: currentTheme.borderColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row( // Using row + expanded to prevent horizontal red box
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fontName,
                        style: fontStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SINE AI — Companion',
                        style: GoogleFonts.getFont(
                          fontName,
                          fontSize: 11,
                          color: currentTheme.textSecondary.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: currentTheme.textSecondary.withValues(alpha: 0.3)),
              ],
            ),
          ),
        );
      },
    );
  }
}
