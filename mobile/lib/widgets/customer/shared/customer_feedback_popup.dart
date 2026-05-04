import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

Future<void> showCustomerFeedbackPopup({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  Color iconStartColor = const Color(0xFFC47A3D),
  Color iconEndColor = const Color(0xFFF6D38B),
  String buttonText = 'تمام',
}) async {
  final bool isDark = AppThemeColors.isDark(context);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            decoration: BoxDecoration(
              color: AppThemeColors.card(dialogContext),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppThemeColors.border(dialogContext),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        iconStartColor,
                        iconEndColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconStartColor.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(dialogContext),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF6D38B)
                        : const Color(0xFF9A5A38),
                    fontSize: 15.5,
                    height: 1.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC47A3D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}