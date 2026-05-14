import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/localization/app_strings.dart';
import 'package:sine_ai/core/services/entitlement_code_service.dart';
import 'package:sine_ai/themes/theme_extensions.dart';

Future<void> showRedeemCodeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _RedeemCodeSheet(),
  );
}

class _RedeemCodeSheet extends ConsumerStatefulWidget {
  const _RedeemCodeSheet();

  @override
  ConsumerState<_RedeemCodeSheet> createState() => _RedeemCodeSheetState();
}

class _RedeemCodeSheetState extends ConsumerState<_RedeemCodeSheet> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _loading) return;

    setState(() => _loading = true);
    final result = await EntitlementCodeService.redeem(code);
    if (!mounted) return;

    setState(() => _loading = false);

    final theme = Theme.of(context);
    final font = ref.read(fontProvider);

    if (result.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('coupon_success'),
            style: GoogleFonts.getFont(font),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.primary,
        ),
      );
    } else {
      final msg = result.message == 'Code limit reached'
          ? AppStrings.get('coupon_full')
          : AppStrings.get('coupon_invalid');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.getFont(font)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.scaffoldBackgroundColor,
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ext.primaryGradient ??
                          LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary
                            ],
                          ),
                    ),
                    child: const Icon(Icons.confirmation_number_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.get('coupon_hint'),
                      style: GoogleFonts.getFont(
                        font,
                        color: theme.colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _redeem(),
                decoration: InputDecoration(
                  hintText: AppStrings.get('coupon_hint'),
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: Text(
                        AppStrings.get('abhi_nahi'),
                        style: GoogleFonts.getFont(
                          font,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.65),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _redeem,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              AppStrings.get('unlock_button'),
                              style: GoogleFonts.getFont(font,
                                  fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
