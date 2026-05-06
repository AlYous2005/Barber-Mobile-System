import 'package:flutter/material.dart';

class AppThemeColors {
  const AppThemeColors._();

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color pageBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color card(BuildContext context) {
    return isDark(context) ? const Color(0xFF241A14) : Colors.white;
  }

  static Color softCard(BuildContext context) {
    return isDark(context) ? const Color(0xFF2D211A) : const Color(0xFFF9FAFB);
  }

  static Color elevatedCard(BuildContext context) {
    return isDark(context) ? const Color(0xFF30231B) : const Color(0xFFFDFCFA);
  }

  static Color border(BuildContext context) {
    return isDark(context) ? const Color(0xFF4A3529) : const Color(0xFFE5E7EB);
  }

  static Color textPrimary(BuildContext context) {
    return isDark(context) ? const Color(0xFFF8F3ED) : const Color(0xFF111827);
  }

  static Color textSecondary(BuildContext context) {
    return isDark(context) ? const Color(0xFFD6C7B8) : const Color(0xFF6B7280);
  }

  static Color textMuted(BuildContext context) {
    return isDark(context) ? const Color(0xFFB9A898) : const Color(0xFF64748B);
  }

  static Color brandBrown(BuildContext context) {
    return const Color(0xFFC47A3D);
  }
}
