import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:sine_ai/core/services/usage_limit_service.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

class AuraScreen extends ConsumerStatefulWidget {
  const AuraScreen({super.key});
  @override
  ConsumerState<AuraScreen> createState() => _AuraScreenState();
}

class _AuraScreenState extends ConsumerState<AuraScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _breatheController;
  late FlutterTts _flutterTts;
  
  final _inputController = TextEditingController();
  bool _isSpeaking = false;
  bool _isListening = false;
  String _auraMessage = "Hey! Main hun AURA — tera AI companion! 🌟";

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("hi-IN");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.1);
    
    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    
    _startIdleMessageLoop();
  }
  
  void _startIdleMessageLoop() {
    final List<String> messages = [
      "Kya haal hai? 😊",
      "Bolo na, kaisa din raha? ✨",
      "Main yahan hun! 💫",
      "Kuch puchhna hai? 🎯",
      "Teri help ke liye ready! 🚀",
    ];
    
    Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && !_isListening) {
        setState(() {
          _auraMessage = messages[DateTime.now().second % messages.length];
        });
      }
    });
  }
  
  Future<void> _toggleVoice() async {
    final limit = await UsageLimitService.consumeAuraTalk();
    if (!limit.allowed) return;
    
    setState(() => _isListening = !_isListening);
    
    if (_isListening) {
      setState(() => _auraMessage = "Sun raha hun... 🎤");
    } else {
      setState(() => _isSpeaking = false);
    }
  }
  
  Future<void> _speakMessage(String message) async {
    await _flutterTts.speak(message);
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    _breatheController.dispose();
    _flutterTts.stop();
    super.dispose();
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
            Expanded(child: _buildCharacter()),
            _buildVoiceButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final font = ref.watch(fontProvider);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('AURA', style: GoogleFonts.getFont(font, fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: 2)),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            child: Icon(Icons.settings_outlined, color: theme.colorScheme.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacter() {
    final theme = Theme.of(context);
    
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _breatheController]),
        builder: (_, __) {
          final floatY = sin(_floatController.value * pi) * 6;
          final breatheScale = 1.0 + (_breatheController.value * 0.02);
          
          return Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.scale(
              scale: breatheScale,
              child: Image.asset(
                'assets/aura_character/aura_avatar_character.png',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    ),
                  ),
                  child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 80),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessage() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ext.border?.withValues(alpha: 0.2) ?? Colors.transparent),
        ),
        child: Text(
          _auraMessage,
          style: GoogleFonts.getFont(font, fontSize: 15, color: theme.colorScheme.onSurface, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _toggleVoice,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: _isListening 
                ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                : (ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary])),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white, size: 24),
              if (_isListening) ...[
                const SizedBox(width: 10),
                Text(
                  'Listening...',
                  style: GoogleFonts.getFont('Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}