import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

void showBookingSuccessReminderDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withValues(alpha: 0.22)),
              ),
            ),
            Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppThemeColors.card(context),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 30,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppThemeColors.isDark(context)
                            ? const Color(0xFF3D1818)
                            : const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Color(0xFFDC2626),
                        size: 31,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'تنبيه مهم قبل الموعد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemeColors.textPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'يرجى الانتباه إلى هاتفك قبل الموعد بـ 15 دقيقة.\n'
                      'سيتم إرسال إشعار لك لتأكيد حضورك على الموعد.\n'
                      'في حال عدم الرد قد يتم إلغاء الموعد تلقائيًا.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemeColors.isDark(context)
                            ? const Color(0xFFFECACA)
                            : const Color(0xFF7F1D1D),
                        fontSize: 14,
                        height: 1.7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'حسناً',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
