import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/themes/theme_extensions.dart';
import 'stopwatch_controller.dart';
import 'lap_tile.dart';
import 'package:share_plus/share_plus.dart';

class StopwatchScreen extends ConsumerStatefulWidget {
  const StopwatchScreen({super.key});

  @override
  ConsumerState<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends ConsumerState<StopwatchScreen> {
  final StopwatchController _controller = StopwatchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareLaps() {
    if (_controller.laps.isEmpty) return;
    String text = "SINE AI Stopwatch Laps:\n";
    for (int i = 0; i < _controller.laps.length; i++) {
      text += "Lap ${_controller.laps.length - i}: ${_controller.formatTime(_controller.laps[i])}\n";
    }
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        int bestLap = -1;
        int worstLap = -1;
        if (_controller.laps.length > 1) {
          int min = _controller.laps.reduce((a, b) => a < b ? a : b);
          int max = _controller.laps.reduce((a, b) => a > b ? a : b);
          bestLap = min;
          worstLap = max;
        }

        return Column(
          children: [
            const SizedBox(height: 40),
            // Timer Display
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  color: ext.card,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: ext.border ?? Colors.transparent, width: 2),
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: -10),
                  ],
                ),
                child: Text(
                  _controller.formatTime(_controller.milliseconds),
                  style: GoogleFonts.getFont(font, fontSize: 56, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _btn(
                  icon: Icons.refresh_rounded,
                  color: ext.textSecondary ?? Colors.grey,
                  onTap: _controller.milliseconds > 0 ? _controller.reset : null,
                ),
                const SizedBox(width: 32),
                _mainBtn(
                  isRunning: _controller.isRunning,
                  onTap: _controller.isRunning ? _controller.pause : _controller.start,
                  theme: theme,
                  ext: ext,
                ),
                const SizedBox(width: 32),
                _btn(
                  icon: Icons.flag_rounded,
                  color: theme.colorScheme.secondary,
                  onTap: _controller.isRunning ? _controller.lap : null,
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Laps Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LAP HISTORY", style: GoogleFonts.getFont(font, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: ext.textSecondary?.withValues(alpha: 0.4))),
                  if (_controller.laps.isNotEmpty)
                    GestureDetector(
                      onTap: _shareLaps,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                        child: Icon(Icons.share_rounded, size: 16, color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Laps List
            Expanded(
              child: _controller.laps.isEmpty 
              ? Center(child: Text("No laps recorded", style: GoogleFonts.getFont(font, color: ext.textSecondary?.withValues(alpha: 0.3), fontWeight: FontWeight.w600)))
              : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _controller.laps.length,
                itemBuilder: (context, i) {
                  final lapTime = _controller.laps[i];
                  return LapTile(
                    index: _controller.laps.length - i,
                    time: _controller.formatTime(lapTime),
                    isBest: lapTime == bestLap,
                    isWorst: lapTime == worstLap,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _btn({required IconData icon, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap == null ? 0.3 : 1.0,
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _mainBtn({required bool isRunning, required VoidCallback onTap, required ThemeData theme, required AppThemeExtension ext}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86, height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isRunning 
            ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)])
            : (ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary])),
          boxShadow: [
            BoxShadow(color: (isRunning ? Colors.red : theme.colorScheme.primary).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 44),
      ),
    );
  }
}
