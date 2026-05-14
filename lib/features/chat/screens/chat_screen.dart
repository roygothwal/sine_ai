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

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': AppStrings.get('chat_initial'),
      'isUser': false,
    }
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, ext, font),
            Expanded(
              child: _buildMessageList(theme, ext, font),
            ),
            _buildInputBar(theme, ext, font),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppThemeExtension ext, String font) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: ext.border ?? Colors.transparent)),
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
            child: ClipOval(
              child: Image.asset(
                'assets/images/aura_avatar_3d.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SINE CHAT',
                  style: GoogleFonts.getFont(font, 
                    fontSize: 16, 
                    fontWeight: FontWeight.w800, 
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.get('online'),
                      style: GoogleFonts.getFont('Inter',
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showChatOptions(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ext.card,
                border: Border.all(color: ext.border ?? Colors.transparent),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: ext.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext ctx) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Clear Chat'),
              onTap: () {
                setState(() {
                  _messages.clear();
                  _messages.add({
                    'text': AppStrings.get('chat_initial'),
                    'isUser': false,
                  });
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('New Chat'),
              onTap: () {
                setState(() {
                  _messages.clear();
                  _messages.add({
                    'text': AppStrings.get('chat_initial'),
                    'isUser': false,
                  });
                  AIService.clearHistory();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme, AppThemeExtension ext, String font) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (_isTyping && i == _messages.length) return _buildTyping(theme, ext, font);
        return _buildMessage(_messages[i], theme, ext, font);
      },
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg, ThemeData theme, AppThemeExtension ext, String font) {
    final isUser = msg['isUser'] as bool;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              _buildAIMessageAvatar(theme),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: _buildMessageBubble(msg, isUser, theme, ext, font),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIMessageAvatar(ThemeData theme) {
    return Container(
      width: 32,
      height: 32,
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
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/aura_avatar_3d.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isUser, ThemeData theme, AppThemeExtension ext, String font) {
    final gradient = isUser 
        ? LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isUser ? gradient : null,
        color: isUser ? null : ext.card,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: isUser 
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
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
    );
  }

  Widget _buildTyping(ThemeData theme, AppThemeExtension ext, String font) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildAIMessageAvatar(theme),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ext.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _buildTypingDot(i, theme)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int i, ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 400 + i * 150),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: value),
          ),
        );
      },
    );
  }

  Widget _buildInputBar(ThemeData theme, AppThemeExtension ext, String font) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildTextField(theme, ext, font)),
            const SizedBox(width: 8),
            _buildSendButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, AppThemeExtension ext, String font) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: TextField(
        controller: _controller,
        style: GoogleFonts.getFont(font, 
          fontSize: 15, 
          color: theme.colorScheme.onSurface,
          height: 1.3,
        ),
        maxLines: null,
        minLines: 1,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: AppStrings.get('chat_hint'),
          hintStyle: GoogleFonts.getFont(font, 
            color: ext.textSecondary?.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          filled: true,
          fillColor: ext.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          isDense: true,
        ),
      ),
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: _send,
        child: Container(
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
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.send_rounded,
            color: Colors.white,
          size: 20,
        ),
      ),
    ),
    );
  }
}