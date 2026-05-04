import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import 'service_form_widgets.dart';

class ServiceConfirmDialog extends StatelessWidget {
  const ServiceConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            color: AppThemeColors.card(context),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppThemeColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppThemeColors.isDark(context) ? 0.45 : 0.12,
                ),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.textSecondary(context),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: MainActionButton(
                  label: confirmText,
                  icon: Icons.check_rounded,
                  color: confirmColor,
                  onTap: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: SecondaryActionButton(
                  label: 'إلغاء',
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
