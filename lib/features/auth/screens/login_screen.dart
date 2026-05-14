import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sine_ai/core/routing/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _googleLoading = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) { _showSnack(AppStrings.get('enter_email')); return; }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) { _showSnack(AppStrings.get('invalid_email')); return; }
    if (password.isEmpty) { _showSnack(AppStrings.get('enter_password')); return; }

    try {
      setState(() => _isLoading = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (!mounted) return;
        _showSnack(AppStrings.get('email_not_verified'));
        context.go(RouteNames.verifyEmail);
        return;
      }
      if (mounted) context.go(RouteNames.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnack(_authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) { _showSnack(AppStrings.get('enter_email_reset')); return; }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) { _showSnack(AppStrings.get('invalid_email')); return; }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnack(AppStrings.get('reset_link_sent'));
    } catch (e) {
      _showSnack(AppStrings.get('error_reset_link'));
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return AppStrings.get('account_not_found');
      case 'wrong-password': return AppStrings.get('incorrect_password');
      default: return AppStrings.get('login_failed');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      setState(() => _googleLoading = true);
      await GoogleSignIn().signOut();
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn().timeout(const Duration(seconds: 25));
      if (googleUser == null) { _showSnack(AppStrings.get('google_cancel')); return; }
      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: auth.accessToken, idToken: auth.idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) context.go(RouteNames.home);
    } on TimeoutException {
      _showSnack(AppStrings.get('google_timeout'));
    } catch (_) {
      _showSnack(AppStrings.get('google_setup_error'));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _setLang(String l) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', l);
    setState(() => AppStrings.currentLanguage = l);
  }

  void _showLangPicker() {
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
                onTap: () { Navigator.pop(context); _setLang(l['key']!); },
                leading: Text(l['flag']!),
                title: Text(l['native']!, style: GoogleFonts.outfit(color: theme.colorScheme.onSurface)),
              );
            },
          ),
        );
      }
    );
  }

  void _showSnack(String m) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m, style: GoogleFonts.outfit()), backgroundColor: theme.colorScheme.primary, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: _langBtn(theme)),
              const SizedBox(height: 18),
              Center(child: _logo(theme)),
              const SizedBox(height: 32),
              Text(AppStrings.get('welcome_sine'), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 6),
              Text(AppStrings.get('future_waiting'), style: GoogleFonts.outfit(fontSize: 15, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 36),
              _field(_emailController, AppStrings.get('email'), Icons.alternate_email_rounded, theme),
              const SizedBox(height: 14),
              _field(_passwordController, AppStrings.get('password'), Icons.fingerprint_rounded, theme, isPassword: true),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _forgotPassword, child: Text(AppStrings.get('forgot_password'), style: GoogleFonts.outfit(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13))),
              ),
              const SizedBox(height: 20),
              _loginBtn(theme),
              const SizedBox(height: 24),
              Center(child: TextButton(onPressed: () => context.push(RouteNames.createAccount), child: Text(AppStrings.get('create_account'), style: GoogleFonts.outfit(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)))),
              const SizedBox(height: 20),
              _googleBtn(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langBtn(ThemeData theme) {
    final l = AppStrings.allLanguages.firstWhere((e) => e['key'] == AppStrings.currentLanguage);
    return GestureDetector(onTap: _showLangPicker, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))), child: Text('${l['flag']} ${l['native']}', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12))));
  }

  Widget _logo(ThemeData theme) {
    return Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary), child: Center(child: Text('S∿', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white))));
  }

  Widget _field(TextEditingController c, String l, IconData i, ThemeData theme, {bool isPassword = false}) {
    return TextField(
      controller: c, 
      obscureText: isPassword && _obscurePassword,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Icon(i),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
      ),
    );
  }

  Widget _loginBtn(ThemeData theme) {
    return SizedBox(
      width: double.infinity, height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login, 
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(AppStrings.get('login'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16))
      ),
    );
  }

  Widget _googleBtn(ThemeData theme) {
    return SizedBox(
      width: double.infinity, height: 58,
      child: OutlinedButton(
        onPressed: _googleLoading ? null : _loginWithGoogle, 
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
        ), 
        child: _googleLoading ? const CircularProgressIndicator() : Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(width: 12), Text(AppStrings.get('google_login'))])
      ),
    );
  }
}
