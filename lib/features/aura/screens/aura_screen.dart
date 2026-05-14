import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:sine_ai/core/services/usage_limit_service.dart';
import 'package:sine_ai/shared/cards/upgrade_prompt.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

class AuraScreen extends ConsumerStatefulWidget {
  const AuraScreen({super.key});
  @override
  ConsumerState<AuraScreen> createState() => _AuraScreenState();
}

class _AuraScreenState extends ConsumerState<AuraScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _mouthController;
  late AnimationController _blinkController;

  final _inputController = TextEditingController();
  bool _isSpeaking = false;
  final bool _isLoading = false;
  bool _isListening = false;
  String _auraMessage = "Hey! Main hun AURA — tera apna AI dost 🌟";

  final List<String> _idleMessages = [
    "Aaj ka din kaisa raha? 😊",
    "Koi goal set kiya aaj? 💪",
    "Main hamesha yahan hun! 🤝",
    "Kuch baat karni hai? Bol! 🎯",
    "Teri smile meri energy hai! ⚡",
    "Kya soch raha hai? 🤔",
    "Aaj kuch naya seekha? 📚",
  ];

  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _startBlinking();
    _startIdleMessages();
  }

  void _startBlinking() {
    Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  void _startIdleMessages() {
    _idleTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && !_isSpeaking && !_isLoading) {
        setState(() {
          _auraMessage = _idleMessages[Random().nextInt(_idleMessages.length)];
        });
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    _mouthController.dispose();
    _blinkController.dispose();
    _inputController.dispose();
    _idleTimer?.cancel();
    super.dispose();
  }

  void _toggleVoice() async {
    HapticFeedback.mediumImpact();
    final limit = await UsageLimitService.consumeAuraTalk();
    if (!limit.allowed) {
      if (!mounted) return;
      showUpgradePrompt(context, limit);
      return;
    }
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      setState(() {
        _auraMessage = "Sun raha hun... bolo! 🎤";
        _isSpeaking = true;
      });
    } else {
      setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCharacterArea()),
            _buildSpeechBubble(),
            _buildPremiumBanner(),
            _buildVoiceButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SINE AI',
                style: GoogleFonts.getFont(font,
                  fontSize: 11,
                  color: ext.textSecondary?.withValues(alpha: 0.4),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                AppStrings.get('aura'),
                style: GoogleFonts.getFont(font,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.green.withValues(alpha: 0.1),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                const SizedBox(width: 8),
                Text(AppStrings.get('online'), style: GoogleFonts.getFont(font, fontSize: 12, color: Colors.green, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea() {
    final theme = Theme.of(context);

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _orbitController, _pulseController]),
        builder: (_, __) {
          final floatOffset = sin(_floatController.value * pi) * 15;
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: SizedBox(
              width: 260, height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Core Glow (Controlled)
                  Container(
                    width: 180 + _pulseController.value * 15,
                    height: 180 + _pulseController.value * 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12 + _pulseController.value * 0.04),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Orbit Rings
                  Transform.rotate(
                    angle: _orbitController.value * 2 * pi,
                    child: _buildOrbitRing(220, theme.colorScheme.primary, 8),
                  ),
                  Transform.rotate(
                    angle: -_orbitController.value * 2 * pi * 0.5,
                    child: _buildOrbitRing(170, theme.colorScheme.secondary, 5),
                  ),
                  // Face
                  _buildFace(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFace() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _mouthController, _blinkController]),
      builder: (_, __) {
        return Container(
          width: 130, height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3 + _pulseController.value * 0.1),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _FacePainter(
              mouthOpen: _isSpeaking ? _mouthController.value : 0,
              blinkValue: _blinkController.value,
              isSpeaking: _isSpeaking,
              accentColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitRing(double size, Color color, int dots) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _OrbitPainter(color: color, dotCount: dots)),
    );
  }

  Widget _buildSpeechBubble() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: ext.border ?? Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: _isLoading
            ? Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => _buildDot(i)))
            : Text(
                _auraMessage,
                style: GoogleFonts.getFont(font, fontSize: 15, color: theme.colorScheme.onSurface, height: 1.5, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  Widget _buildDot(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 500 + i * 150),
      builder: (_, v, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 8, height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withValues(alpha: v)),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            const Text('🔮', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Text(AppStrings.get('voice_unlock'), style: GoogleFonts.getFont(font, fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
              ),
              child: Text(AppStrings.get('upgrade'), style: GoogleFonts.getFont(font, fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _toggleVoice,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: _isListening
                ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                : (ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary])),
            boxShadow: [
              BoxShadow(
                color: (_isListening ? Colors.green : theme.colorScheme.primary).withValues(alpha: 0.25),
                blurRadius: 12, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 14),
              Text(
                _isListening ? 'Sun raha hun...' : 'AURA se baat karo',
                style: GoogleFonts.getFont(font, fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  final double mouthOpen;
  final double blinkValue;
  final bool isSpeaking;
  final Color accentColor;

  _FacePainter({
    required this.mouthOpen,
    required this.blinkValue,
    required this.isSpeaking,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final eyePaint = Paint()..color = accentColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    final eyeH = 12 * (1 - blinkValue);
    
    // Eyes
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 22, cy - 12), width: 18, height: eyeH + 1), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 22, cy - 12), width: 18, height: eyeH + 1), eyePaint);

    if (blinkValue < 0.8) {
      final pupilPaint = Paint()..color = Colors.black.withValues(alpha: 0.2);
      canvas.drawCircle(Offset(cx - 20, cy - 14), 4, pupilPaint);
      canvas.drawCircle(Offset(cx + 24, cy - 14), 4, pupilPaint);
    }

    // Mouth
    if (isSpeaking) {
      final mouthPaint = Paint()..color = accentColor.withValues(alpha: 0.9)..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 20), width: 30, height: 8 + mouthOpen * 16), mouthPaint);
    } else {
      final smilePaint = Paint()..color = accentColor.withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
      final path = Path();
      path.moveTo(cx - 16, cy + 18);
      path.quadraticBezierTo(cx, cy + 28, cx + 16, cy + 18);
      canvas.drawPath(path, smilePaint);
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.mouthOpen != mouthOpen || old.blinkValue != blinkValue || old.isSpeaking != isSpeaking;
}

class _OrbitPainter extends CustomPainter {
  final Color color;
  final int dotCount;
  _OrbitPainter({required this.color, required this.dotCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final ringPaint = Paint()..color = color.withValues(alpha: 0.1)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);
    final dotPaint = Paint()..color = color.withValues(alpha: 0.5);
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi;
      canvas.drawCircle(Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), 3.5, dotPaint);
    }
  }
  @override
  bool shouldRepaint(_OrbitPainter old) => false;
}
