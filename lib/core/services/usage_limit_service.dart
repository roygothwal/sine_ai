import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LimitCheck {
  final bool allowed;
  final String title;
  final String message;
  final int remaining;
  final int limit;

  const LimitCheck({
    required this.allowed,
    required this.title,
    required this.message,
    required this.remaining,
    required this.limit,
  });

  factory LimitCheck.allowed({required int remaining, required int limit}) {
    return LimitCheck(
      allowed: true,
      title: '',
      message: '',
      remaining: remaining,
      limit: limit,
    );
  }

  factory LimitCheck.blocked({
    required String title,
    required String message,
    required int limit,
  }) {
    return LimitCheck(
      allowed: false,
      title: title,
      message: message,
      remaining: 0,
      limit: limit,
    );
  }
}

class CouponResult {
  final bool success;
  final String message;

  const CouponResult({required this.success, required this.message});
}

class UsageLimitService {
  static const String founderCoupon = 'roygothwal';
  static const int founderCouponMaxUsers = 5;

  static const int freeDailyChatLimit = 10;
  static const int freeDailyAuraTalkLimit = 5;

  // Product rule: alarms, reminders and themes stay free.
  static Future<LimitCheck> canUseAlarmOrReminder() async {
    return LimitCheck.allowed(remaining: 999, limit: 999);
  }

  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  static String _todayKey(String feature) {
    final now = DateTime.now();
    final day =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'usage_${_uid}_${feature}_$day';
  }

  static Future<bool> isProUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_pro_user') == true) return true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));
      final data = doc.data() ?? {};
      final plan = '${data['plan'] ?? data['subscriptionPlan'] ?? 'free'}'
          .toLowerCase()
          .trim();
      final status = '${data['subscriptionStatus'] ?? data['status'] ?? ''}'
          .toLowerCase()
          .trim();
      const paidPlans = {
        'founder',
        'pro',
        'premium',
        'starter_99',
        'pro_199',
        'ultimate_1999',
      };
      final isPaidPlan = paidPlans.contains(plan);
      final active = data['isPro'] == true ||
          data['premium'] == true ||
          plan == 'pro' ||
          plan == 'premium' ||
          plan == 'founder' ||
          isPaidPlan ||
          status == 'active';

      await prefs.setBool('is_pro_user', active);
      return active;
    } catch (_) {
      return prefs.getBool('is_pro_user') ?? false;
    }
  }

  static Future<CouponResult> redeemCoupon(String rawCode) async {
    final code = rawCode.trim().toLowerCase();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const CouponResult(
        success: false,
        message: 'Pehle login karo, phir coupon lagao.',
      );
    }

    if (code != founderCoupon) {
      return const CouponResult(
        success: false,
        message: 'Coupon code galat hai.',
      );
    }

    try {
      final couponRef =
          FirebaseFirestore.instance.collection('coupons').doc(founderCoupon);
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final couponSnap = await transaction.get(couponRef);
        final data = couponSnap.data() ?? {};
        final usedBy = List<String>.from(data['usedBy'] ?? const <String>[]);
        final maxUses =
            (data['maxUses'] as num?)?.toInt() ?? founderCouponMaxUsers;

        if (!usedBy.contains(user.uid) && usedBy.length >= maxUses) {
          throw StateError('coupon-full');
        }

        if (!usedBy.contains(user.uid)) {
          usedBy.add(user.uid);
        }

        transaction.set(
            couponRef,
            {
              'code': founderCoupon,
              'maxUses': founderCouponMaxUsers,
              'usedBy': usedBy,
              'usedCount': usedBy.length,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));

        transaction.set(
            userRef,
            {
              'isPro': true,
              'plan': 'founder',
              'subscriptionStatus': 'active',
              'couponCode': founderCoupon,
              'couponRedeemedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      }).timeout(const Duration(seconds: 10));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_pro_user', true);

      return const CouponResult(
        success: true,
        message: 'Coupon applied. Founder Pro unlock ho gaya.',
      );
    } on StateError {
      return const CouponResult(
        success: false,
        message: 'Ye coupon 5 users use kar chuke hain.',
      );
    } catch (_) {
      return const CouponResult(
        success: false,
        message: 'Coupon apply nahi hua. Firestore rules/network check karo.',
      );
    }
  }

  static Future<LimitCheck> consumeChatMessage() {
    return _consumeDaily(
      feature: 'chat',
      limit: freeDailyChatLimit,
      blockedTitle: 'Free chat limit khatam',
      blockedMessage:
          'Aaj ke free messages complete ho gaye. Unlimited SINE AI chat ke liye plan unlock karo.',
    );
  }

  static Future<LimitCheck> consumeAuraTalk() {
    return _consumeDaily(
      feature: 'aura_talk',
      limit: freeDailyAuraTalkLimit,
      blockedTitle: 'AURA talk limit khatam',
      blockedMessage:
          'Free AURA talk limit complete ho gayi. Unlimited AURA ke liye plan unlock karo.',
    );
  }

  static Future<LimitCheck> canCustomizeAura() async {
    if (await isProUser()) {
      return LimitCheck.allowed(remaining: 999, limit: 999);
    }
    return LimitCheck.blocked(
      title: 'AURA customization locked',
      message:
          'AURA ka look, voice, name aur advanced personality customize karne ke liye Pro unlock karo.',
      limit: 0,
    );
  }

  static Future<LimitCheck> _consumeDaily({
    required String feature,
    required int limit,
    required String blockedTitle,
    required String blockedMessage,
  }) async {
    if (await isProUser()) {
      return LimitCheck.allowed(remaining: 999, limit: 999);
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey(feature);
    final used = prefs.getInt(key) ?? 0;

    if (used >= limit) {
      return LimitCheck.blocked(
        title: blockedTitle,
        message: blockedMessage,
        limit: limit,
      );
    }

    await prefs.setInt(key, used + 1);
    return LimitCheck.allowed(remaining: limit - used - 1, limit: limit);
  }
}
