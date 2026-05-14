import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

class LapTile extends ConsumerWidget {
  final int index;
  final String time;
  final bool isBest;
  final bool isWorst;

  const LapTile({
    super.key,
    required this.index,
    required this.time,
    this.isBest = false,
    this.isWorst = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    Color textColor = theme.colorScheme.onSurface;
    if (isBest) textColor = Colors.greenAccent;
    if (isWorst) textColor = Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBest 
            ? Colors.greenAccent.withValues(alpha: 0.3) 
            : (isWorst ? Colors.redAccent.withValues(alpha: 0.3) : (ext.border ?? Colors.transparent)),
          width: (isBest || isWorst) ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lap ${index.toString().padLeft(2, '0')}',
            style: GoogleFonts.getFont(font, fontSize: 14, color: ext.textSecondary, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              if (isBest) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.flash_on_rounded, color: Colors.greenAccent, size: 14)),
              if (isWorst) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.trending_down_rounded, color: Colors.redAccent, size: 14)),
              Text(
                time,
                style: GoogleFonts.getFont(font, fontSize: 16, color: textColor, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
