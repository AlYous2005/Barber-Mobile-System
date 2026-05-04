import 'package:flutter/material.dart';

import 'customer_profile_fields.dart';
import 'customer_profile_shared_widgets.dart';

class CustomerPasswordBox extends StatelessWidget {
  const CustomerPasswordBox({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.showCurrentPassword,
    required this.showNewPassword,
    required this.showConfirmPassword,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  final bool showCurrentPassword;
  final bool showNewPassword;
  final bool showConfirmPassword;

  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    return CustomerProfileCardShell(
      child: Column(
        children: [
          const CustomerProfileSectionHeader(
            icon: Icons.lock_rounded,
            title: 'تغيير كلمة المرور',
            subtitle:
                'اترك الحقول فارغة إذا كنت لا تريد تغيير كلمة المرور الآن.',
          ),
          const SizedBox(height: 18),
          CustomerPasswordField(
            label: 'كلمة المرور الحالية',
            controller: currentPasswordController,
            isVisible: showCurrentPassword,
            onToggleVisibility: onToggleCurrent,
          ),
          const SizedBox(height: 14),
          CustomerPasswordField(
            label: 'كلمة المرور الجديدة',
            controller: newPasswordController,
            isVisible: showNewPassword,
            onToggleVisibility: onToggleNew,
          ),
          const SizedBox(height: 14),
          CustomerPasswordField(
            label: 'تأكيد كلمة المرور الجديدة',
            controller: confirmPasswordController,
            isVisible: showConfirmPassword,
            onToggleVisibility: onToggleConfirm,
          ),
        ],
      ),
    );
  }
}
