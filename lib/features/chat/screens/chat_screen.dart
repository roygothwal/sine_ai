import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:sine_ai/services/ai_service.dart';
import 'package:sine_ai/core/services/usage_limit_service.dart';
import 'package:sine_ai/shared/cards/upgrade_prompt.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': AppStrings.get('chat_initial'),
      'isUser': false,
    }
  ];
  bool _isTyping = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    final limit = await UsageLimitService.consumeChatMessage();
    if (!limit.allowed) {
      if (!mounted) return;
      showUpgradePrompt(context, limit);
      return;
    }

    _controller.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isTyping = true;
    });
    _scrollToBottom();

    final reply = await AIService.sendMessage(text);
    print("AI Response: $reply");

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'text': reply, 'isUser': false});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(bottom: BorderSide(color: ext.border ?? Colors.transparent)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SINE CHAT', style: GoogleFonts.getFont(font, fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                          const SizedBox(width: 4),
                          Text(AppStrings.get('online'), style: GoogleFonts.getFont(font, fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_isTyping && i == _messages.length) return _buildTyping();
                  return _buildMessage(_messages[i]);
                },
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: ext.border ?? Colors.transparent)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ext.card,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: ext.border ?? Colors.transparent),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.getFont(font, fontSize: 14, color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: AppStrings.get('chat_hint'),
                          hintStyle: GoogleFonts.getFont(font, color: ext.textSecondary?.withValues(alpha: 0.5)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                        boxShadow: [
                          BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['isUser'] as bool;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: ext.surface, border: Border.all(color: ext.border ?? Colors.transparent)),
              child: Icon(Icons.smart_toy_rounded, color: theme.colorScheme.primary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? theme.colorScheme.primary : ext.card,
                gradient: isUser ? ext.primaryGradient : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: isUser ? null : Border.all(color: ext.border ?? Colors.transparent),
                boxShadow: [
                  if (isUser) BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Text(
                msg['text'] as String,
                style: GoogleFonts.getFont(font, 
                  fontSize: 14, 
                  color: isUser ? Colors.white : theme.colorScheme.onSurface, 
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTyping() {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ext.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ext.border ?? Colors.transparent),
            ),
            child: Row(
              children: List.generate(3, (i) => _dot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.2, end: 1.0),
      duration: Duration(milliseconds: 400 + i * 150),
      builder: (_, v, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 6, height: 6,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withValues(alpha: v)),
      ),
    );
  }
}
