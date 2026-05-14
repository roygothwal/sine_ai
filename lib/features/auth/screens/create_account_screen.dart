import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sine_ai/core/routing/route_names.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedAvatar = '🤖';
  String _auraPersonality = 'friendly';
  bool _isLoading = false;

  final List<String> _avatarOptions = [
    '🤖', '👨‍💻', '🧑‍🎤', '👩‍🎤', '🦸', '🧙‍♂️', '🦊', '🐺', '🐉', '⚡', '🔮', '💎'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _finish();
    }
  }

  void _finish() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_.]'), '');

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack(AppStrings.get('name_email_pass_req'));
      _goToPage(0);
      return;
    }

    if (username.length < 3) {
      _showSnack(AppStrings.get('username_req'));
      _goToPage(1);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final usernameSnap = await FirebaseFirestore.instance.collection('usernames').doc(username).get();
      if (usernameSnap.exists) {
        _showSnack(AppStrings.get('username_taken'));
        _goToPage(1);
        return;
      }

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) throw Exception();

      await user.updateDisplayName(name);

      final pendingData = {
        'name': name,
        'email': email,
        'username': username,
        'avatar': _selectedAvatar,
        'auraPersonality': _auraPersonality,
        'bio': _bioController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await user.sendEmailVerification();

      if (mounted) {
        context.pushReplacement(RouteNames.verifyEmail, extra: pendingData);
      }
    } catch (e) {
      _showSnack(AppStrings.get('error_generic'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToPage(int p) {
    _pageController.animateToPage(p, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    setState(() => _currentPage = p);
  }

  void _showSnack(String m) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m, style: GoogleFonts.outfit()), backgroundColor: theme.colorScheme.primary, behavior: SnackBarBehavior.floating));
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      AppStrings.currentLanguage = lang;
    });
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          color: theme.scaffoldBackgroundColor,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppStrings.allLanguages.length,
            itemBuilder: (_, i) {
              final l = AppStrings.allLanguages[i];
              return ListTile(
                onTap: () { Navigator.pop(context); _setLanguage(l['key']!); },
                leading: Text(l['flag']!),
                title: Text(l['native']!, style: TextStyle(color: theme.colorScheme.onSurface)),
              );
            },
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface), onPressed: () => context.pop()),
                  GestureDetector(
                    onTap: _showPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                      child: Text(AppStrings.currentLanguage.toUpperCase(), style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: i <= _currentPage ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))),
                )),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildP1(theme), _buildP2(theme), _buildP3(theme)],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextPage,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(AppStrings.get(_currentPage == 2 ? 'create_account' : 'next'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildP1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.get('create_account'), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 30),
          _field(_nameController, AppStrings.get('full_name'), Icons.person_outline, theme),
          const SizedBox(height: 16),
          _field(_emailController, AppStrings.get('email'), Icons.alternate_email, theme, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _field(_passwordController, AppStrings.get('password'), Icons.lock_outline, theme, isPassword: true),
        ],
      ),
    );
  }

  Widget _buildP2(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.get('choose_avatar'), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: _avatarOptions.map((a) => GestureDetector(
              onTap: () => setState(() => _selectedAvatar = a),
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _selectedAvatar == a ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.onSurface.withValues(alpha: 0.05), border: Border.all(color: _selectedAvatar == a ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 2)),
                child: Center(child: Text(a, style: const TextStyle(fontSize: 28))),
              ),
            )).toList(),
          ),
          const SizedBox(height: 30),
          _field(_usernameController, '@username', Icons.tag, theme),
          const SizedBox(height: 16),
          _field(_bioController, AppStrings.get('bio_hint'), Icons.edit_note, theme, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildP3(ThemeData theme) {
    final pers = [
      {'key': 'friendly', 'label': AppStrings.get('friendly'), 'desc': AppStrings.get('friendly_desc')},
      {'key': 'savage', 'label': AppStrings.get('savage'), 'desc': AppStrings.get('savage_desc')},
      {'key': 'motivator', 'label': AppStrings.get('motivator'), 'desc': AppStrings.get('motivator_desc')},
      {'key': 'chill', 'label': AppStrings.get('chill'), 'desc': AppStrings.get('chill_desc')},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.get('aura_personality'), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 20),
          ...pers.map((p) => GestureDetector(
            onTap: () => setState(() => _auraPersonality = p['key']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: _auraPersonality == p['key'] ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.onSurface.withValues(alpha: 0.05), border: Border.all(color: _auraPersonality == p['key'] ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1))),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['label']!, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  Text(p['desc']!, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
                ])),
                if (_auraPersonality == p['key']) Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ]),
            ),
          )),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i, ThemeData theme, {bool isPassword = false, TextInputType? keyboard, int maxLines = 1}) {
    return TextField(
      controller: c, obscureText: isPassword && _obscurePassword, keyboardType: keyboard, maxLines: maxLines,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Icon(i),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
      ),
    );
  }
}
