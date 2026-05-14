import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sine_ai/core/routing/route_names.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:sine_ai/core/services/usage_limit_service.dart';
import 'package:sine_ai/shared/cards/upgrade_prompt.dart';
import 'package:sine_ai/shared/sheets/redeem_code_sheet.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingProfile = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) setState(() { _profile = snap.data(); _loadingProfile = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _showAuraLocked() async {
    final limit = await UsageLimitService.canCustomizeAura();
    if (!mounted) return;
    if (!limit.allowed) showUpgradePrompt(context, limit);
  }

  Future<void> _showSubscriptionSheet() async {
    final limit = LimitCheck.blocked(title: AppStrings.get('pro_title'), message: AppStrings.get('pro_message'), limit: 0);
    await showUpgradePrompt(context, limit);
  }

  void _showPrivacy() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.read(fontProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('privacy_title'), style: GoogleFonts.getFont(font, color: theme.colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(AppStrings.get('privacy_desc'), style: GoogleFonts.getFont(font, color: ext.textSecondary?.withValues(alpha: 0.7), height: 1.5, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('done')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    HapticFeedback.mediumImpact();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          return _LanguageSheet(
            selected: ref.watch(languageProvider),
            onSelect: (lang) {
              ref.read(languageProvider.notifier).setLanguage(lang);
            },
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);
    
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildAvatar(theme, ext),
              const SizedBox(height: 16),
              if (_loadingProfile) CircularProgressIndicator(color: theme.colorScheme.primary)
              else ...[
                Text(_profile?['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? AppStrings.get('default_user_name'),
                    style: GoogleFonts.getFont(font, fontSize: 26, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                Text('@${_profile?['username'] ?? 'user'}',
                    style: GoogleFonts.getFont(font, fontSize: 14, color: ext.textSecondary?.withValues(alpha: 0.5), fontWeight: FontWeight.w700)),
              ],
              const SizedBox(height: 32),
              _buildStatsRow(theme, ext, font),
              const SizedBox(height: 24),
              _buildUpgradeCard(theme, ext, font),
              const SizedBox(height: 32),
              _buildSettingsList(theme, ext, font),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, AppThemeExtension ext) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)],
          ),
          child: Center(child: Text(_profile?['avatar'] ?? '🤖', style: const TextStyle(fontSize: 48))),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: theme.colorScheme.onSurface, shape: BoxShape.circle, border: Border.all(color: theme.scaffoldBackgroundColor, width: 2)),
            child: Icon(Icons.edit_rounded, color: theme.scaffoldBackgroundColor, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme, AppThemeExtension ext, String font) {
    return Row(
      children: [
        _statItem('47', AppStrings.get('chats'), theme, ext, font),
        const SizedBox(width: 12),
        _statItem('12', AppStrings.get('goals'), theme, ext, font),
        const SizedBox(width: 12),
        _statItem('3🔥', AppStrings.get('streak'), theme, ext, font),
      ],
    );
  }

  Widget _statItem(String val, String label, ThemeData theme, AppThemeExtension ext, String font) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: ext.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: ext.border ?? Colors.transparent)),
        child: Column(
          children: [
            Text(val, style: GoogleFonts.getFont(font, fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
            Text(label, style: GoogleFonts.getFont(font, fontSize: 11, fontWeight: FontWeight.w700, color: ext.textSecondary?.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(ThemeData theme, AppThemeExtension ext, String font) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          const Text('👑', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.get('free_plan'), style: GoogleFonts.getFont(font, fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                Text(AppStrings.get('upgrade_unlock'), style: GoogleFonts.getFont(font, fontSize: 12, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Text(AppStrings.get('upgrade'), style: GoogleFonts.getFont(font, fontSize: 13, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(ThemeData theme, AppThemeExtension ext, String font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(AppStrings.get('settings').toUpperCase(), style: GoogleFonts.getFont(font, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: ext.textSecondary?.withValues(alpha: 0.4))),
        ),
        _settingTile('🌐', AppStrings.get('language_label'), AppStrings.get('choose_language'), theme, ext, font, onTap: _showLanguagePicker),
        _settingTile('🎨', AppStrings.get('appearance'), AppStrings.get('themes_free'), theme, ext, font, onTap: () => context.push(RouteNames.appearance)),
        _settingTile('🤖', AppStrings.get('aura_personality'), AppStrings.get('aura_customization'), theme, ext, font, onTap: _showAuraLocked),
        _settingTile('🏷️', AppStrings.get('coupon_hint'), AppStrings.get('pro_unlock_success'), theme, ext, font, onTap: () => showRedeemCodeSheet(context)),
        _settingTile('🔒', AppStrings.get('privacy_label'), AppStrings.get('privacy_sub'), theme, ext, font, onTap: _showPrivacy),
        _settingTile('💳', AppStrings.get('subscription_label'), AppStrings.get('subscription_sub'), theme, ext, font, onTap: _showSubscriptionSheet),
        _settingTile('🚪', AppStrings.get('logout_label'), AppStrings.get('logout_sub'), theme, ext, font, color: theme.colorScheme.error, onTap: _logout),
      ],
    );
  }

  Widget _settingTile(String icon, String title, String sub, ThemeData theme, AppThemeExtension ext, String font, {VoidCallback? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ext.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: ext.border ?? Colors.transparent)),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.getFont(font, fontSize: 15, fontWeight: FontWeight.w800, color: color ?? theme.colorScheme.onSurface)),
                  Text(sub, style: GoogleFonts.getFont(font, fontSize: 12, color: ext.textSecondary?.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ext.textSecondary?.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }
}

class _LanguageSheet extends ConsumerWidget {
  final String selected;
  final Function(String) onSelect;

  const _LanguageSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: ext.border)),
          const SizedBox(height: 24),
          Text(AppStrings.get('choose_language'), style: GoogleFonts.getFont(font, fontSize: 22, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppStrings.allLanguages.length,
              itemBuilder: (_, i) {
                final lang = AppStrings.allLanguages[i];
                final isSelected = selected == lang['key'];
                return GestureDetector(
                  onTap: () {
                    onSelect(lang['key']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : ext.card,
                      border: Border.all(color: isSelected ? theme.colorScheme.primary : ext.border ?? Colors.transparent, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang['native']!, style: GoogleFonts.getFont(font, fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                              Text(lang['name']!, style: GoogleFonts.getFont(font, fontSize: 12, color: ext.textSecondary?.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        if (isSelected) Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
