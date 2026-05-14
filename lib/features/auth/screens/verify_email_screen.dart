import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:sine_ai/core/routing/route_names.dart';
import 'package:sine_ai/localization/app_strings.dart';

class VerifyEmailScreen extends StatefulWidget {
  final Map<String, dynamic>? pendingData;
  const VerifyEmailScreen({super.key, this.pendingData});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {
  Timer? _checkTimer;
  Timer? _countdownTimer;
  bool _sending = false;
  bool _verified = false;
  bool _redirecting = false;
  int _secondsLeft = 600; 

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _selectedLang = AppStrings.currentLanguage;

  @override
  void initState() {
    super.initState();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeIn),
    );

    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkVerification();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _handleTimeout();
        }
      });
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    _successController.dispose();
    super.dispose();
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _handleTimeout() async {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try { await user.delete(); } catch (_) {}
    }
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    _showSnack(AppStrings.get('timer_expired'), Colors.red);
    context.go(RouteNames.login);
  }

  Future<void> _checkVerification() async {
    if (_redirecting || _verified) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed != null && refreshed.emailVerified) {
        _checkTimer?.cancel();
        _countdownTimer?.cancel();

        if (widget.pendingData != null) {
          final uid = refreshed.uid;
          final username = widget.pendingData!['username'];
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final uRef = FirebaseFirestore.instance.collection('usernames').doc(username);
            final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
            transaction.set(uRef, {'uid': uid, 'username': username, 'createdAt': FieldValue.serverTimestamp(), 'status': 'active'});
            transaction.set(userRef, {...widget.pendingData!, 'uid': uid, 'status': 'active', 'emailVerified': true, 'verifiedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
          });
        }

        if (!mounted) return;
        setState(() => _verified = true);
        _successController.forward();
        _redirecting = true;
        await Future.delayed(const Duration(seconds: 4));
        if (!mounted) return;
        await FirebaseAuth.instance.signOut();
        context.go(RouteNames.login);
      }
    } catch (_) {}
  }

  Future<void> _resend() async {
    if (_sending) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _sending = true);
    try {
      await user.sendEmailVerification();
      if (mounted) {
        setState(() => _secondsLeft = 600);
        _showSnack(AppStrings.get('email_sent_to'), Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnack(AppStrings.get('error_generic'), Colors.red);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.outfit()), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _selectedLang = lang;
      AppStrings.currentLanguage = lang;
    });
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: AppStrings.allLanguages.length,
          itemBuilder: (_, i) {
            final lang = AppStrings.allLanguages[i];
            return ListTile(
              onTap: () { Navigator.pop(context); _setLanguage(lang['key']!); },
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
              title: Text(lang['native']!, style: const TextStyle(color: Colors.white)),
              trailing: lang['key'] == _selectedLang ? const Icon(Icons.check, color: Color(0xFFFFC107)) : null,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFF050202),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: _verified 
            ? const RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF0D2511), Color(0xFF050202)])
            : const RadialGradient(center: Alignment.topCenter, radius: 1.5, colors: [Color(0xFF0F0F0F), Color(0xFF050202)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!_verified) Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showLanguagePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10), color: Colors.white.withValues(alpha: 0.05)),
                      child: Text(AppStrings.currentLanguage.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: _verified ? _buildSuccessUI() : _buildPendingUI(email),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withValues(alpha: 0.15), border: Border.all(color: Colors.green, width: 2), boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.2), blurRadius: 40)]),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 85),
          ),
        ),
        const SizedBox(height: 40),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Text(AppStrings.get('account_created_success'), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 16),
              Text(AppStrings.get('please_login_continue'), style: GoogleFonts.outfit(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.green, strokeWidth: 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingUI(String email) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(36), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40)]),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFC107).withValues(alpha: 0.05)), child: const Icon(Icons.mark_email_unread_outlined, color: Color(0xFFFFC107), size: 40)),
            const SizedBox(height: 32),
            Text(AppStrings.get('verify_email'), style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 12),
            Text(email, style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFFFFC107), fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text(AppStrings.get('click_to_verify'), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.5), height: 1.5)),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white.withValues(alpha: 0.03)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.timer_outlined, color: Color(0xFFFFC107), size: 18),
                const SizedBox(width: 10),
                Text(_timerText, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFFFFC107), letterSpacing: 2)),
              ]),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 60,
              child: OutlinedButton(
                onPressed: _sending ? null : _resend,
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: 0.1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: _sending ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white54) : Text(AppStrings.get('resend_email'), style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity, height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)])),
              child: ElevatedButton(
                onPressed: () => _checkVerification(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: Text(AppStrings.get('i_have_verified'), style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
