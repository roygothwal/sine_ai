import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntitlementRedeemResult {
  final bool success;
  final String message;
  final String? plan;

  const EntitlementRedeemResult({
    required this.success,
    required this.message,
    this.plan,
  });
}

class EntitlementCodeService {
  static const String _collection = 'entitlements_codes';

  /// Redeem a testing entitlement code stored in Firestore.
  ///
  /// Firestore document (id = codeLower):
  /// - active: bool (default true)
  /// - plan: string (e.g. starter_99, pro_199, ultimate_1999)
  /// - maxUses: number (optional)
  /// - usedBy: array<string> (optional)
  /// - expiresAt: timestamp (optional)
  static Future<EntitlementRedeemResult> redeem(String rawCode) async {
    final code = rawCode.trim().toLowerCase();
    if (code.isEmpty) {
      return const EntitlementRedeemResult(
        success: false,
        message: 'Code required',
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const EntitlementRedeemResult(
        success: false,
        message: 'Login required',
      );
    }

    final codeRef = FirebaseFirestore.instance.collection(_collection).doc(code);
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      String? plan;

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(codeRef);
        if (!snap.exists) {
          throw StateError('code-not-found');
        }

        final data = snap.data() ?? <String, dynamic>{};
        final active = data['active'] != false;

        if (!active) {
          throw StateError('code-inactive');
        }

        final expiresAt = data['expiresAt'];
        if (expiresAt is Timestamp) {
          if (expiresAt.toDate().isBefore(DateTime.now())) {
            throw StateError('code-expired');
          }
        }

        final usedBy = List<String>.from(data['usedBy'] ?? const <String>[]);
        final maxUses = (data['maxUses'] as num?)?.toInt();

        if (!usedBy.contains(user.uid)) {
          if (maxUses != null && usedBy.length >= maxUses) {
            throw StateError('code-full');
          }
          usedBy.add(user.uid);
        }

        plan = (data['plan'] as String?)?.trim();
        if (plan == null || plan!.isEmpty) {
          throw StateError('code-invalid-plan');
        }

        tx.set(
          codeRef,
          {
            'code': code,
            'usedBy': usedBy,
            'usedCount': usedBy.length,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        tx.set(
          userRef,
          {
            'plan': plan,
            'subscriptionStatus': 'active',
            'isPro': true,
            'entitlementSource': 'code',
            'entitlementCode': code,
            'entitlementActivatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }).timeout(const Duration(seconds: 12));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_pro_user', true);

      return EntitlementRedeemResult(
        success: true,
        message: 'Unlocked successfully',
        plan: plan,
      );
    } on StateError catch (e) {
      final key = e.message;
      if (key == 'code-full') {
        return const EntitlementRedeemResult(
          success: false,
          message: 'Code limit reached',
        );
      }
      if (key == 'code-expired') {
        return const EntitlementRedeemResult(
          success: false,
          message: 'Code expired',
        );
      }
      if (key == 'code-inactive') {
        return const EntitlementRedeemResult(
          success: false,
          message: 'Code inactive',
        );
      }
      return const EntitlementRedeemResult(
        success: false,
        message: 'Invalid code',
      );
    } catch (_) {
      return const EntitlementRedeemResult(
        success: false,
        message: 'Something went wrong',
      );
    }
  }
}

