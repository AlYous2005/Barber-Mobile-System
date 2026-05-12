import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import 'availability_shared_widgets.dart';

class AvailabilityConfirmDialog extends StatelessWidget {
  const AvailabilityConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.color,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmText;
  final Color color;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
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
                child: AvailabilityPrimaryButton(
                  label: confirmText,
                  icon: Icons.delete_rounded,
                  color: color,
                  onTap: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: AvailabilitySecondaryButton(
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
