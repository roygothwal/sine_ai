import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/theme/theme_manager.dart';

class CustomTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboard;
  final int maxLines;
  final Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboard,
    this.maxLines = 1,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: In real app, themeProvider should point to ThemeManager
    // For now using fallback if provider not yet updated
    final theme = ref.watch(themeManagerProvider).currentTheme;

    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboard,
      maxLines: maxLines,
      onSubmitted: onSubmitted,
      style: TextStyle(color: theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.inputHint),
        prefixIcon: Icon(icon, color: theme.accentPrimary),
        filled: true,
        fillColor: theme.inputFill,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.inputBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.accentPrimary, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        hintStyle: TextStyle(color: theme.inputHint),
      ),
    );
  }
}

// Temporary provider for internal use
final themeManagerProvider = ChangeNotifierProvider((ref) => ThemeManager());
