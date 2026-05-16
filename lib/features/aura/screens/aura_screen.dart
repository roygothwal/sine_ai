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
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildCharacter()),
                const SizedBox(height: 80),
              ],
            ),
            _buildVoiceButton(),
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
          Row(
            children: [
              Text('AURA', style: GoogleFonts.getFont(font, fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: 2)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text('Online', style: GoogleFonts.getFont('Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ],
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
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width * 0.95,
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
    
    return Positioned(
      right: 20,
      bottom: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 28),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _toggleVoice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isListening 
                    ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                    : (ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary])),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}