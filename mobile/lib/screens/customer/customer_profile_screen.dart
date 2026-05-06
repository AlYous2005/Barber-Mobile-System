// UI + popups + navigation
import 'package:flutter/material.dart';

import '../../controllers/customer/customer_profile_controller.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/customer/profile/customer_password_box.dart';
import '../../widgets/customer/profile/customer_profile_form_box.dart';
import '../../widgets/customer/profile/customer_profile_intro_card.dart';
import '../../widgets/customer/profile/customer_profile_shared_widgets.dart';
import '../../widgets/customer/shared/customer_feedback_popup.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    required this.initialDisplayName,
    required this.initialCountryCode,
    required this.initialPhoneNumber,
    this.initialHasProfileImage = false,
  });

  final String initialDisplayName;
  final String initialCountryCode;
  final String initialPhoneNumber;
  final bool initialHasProfileImage;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late final CustomerProfileController controller;

  @override
  void initState() {
    super.initState();

    controller = CustomerProfileController(
      initialDisplayName: widget.initialDisplayName,
      initialCountryCode: widget.initialCountryCode,
      initialPhoneNumber: widget.initialPhoneNumber,
      initialHasProfileImage: widget.initialHasProfileImage,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _addOrChangeImage() async {
    final bool alreadyHadImage = controller.hasProfileImage;

    controller.setHasProfileImage(true);

    await showCustomerFeedbackPopup(
      context: context,
      title: alreadyHadImage ? 'تم تحديث الصورة' : 'تم إضافة الصورة',
      message: alreadyHadImage
          ? 'تم تحديث الصورة بنجاح'
          : 'تم إضافة الصورة بنجاح',
      icon: alreadyHadImage ? Icons.image_rounded : Icons.add_a_photo_rounded,
    );
  }

  Future<void> _removeImage() async {
    controller.setHasProfileImage(false);

    await showCustomerFeedbackPopup(
      context: context,
      title: 'تم إزالة الصورة',
      message: 'تم إزالة الصورة بنجاح',
      icon: Icons.delete_outline_rounded,
      iconStartColor: const Color(0xFFEF4444),
      iconEndColor: const Color(0xFFFCA5A5),
    );
  }

  Future<void> save() async {
    final name = controller.nameController.text.trim();
    final phone = controller.phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الاسم الظاهر')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')));
      return;
    }

    if (!controller.validatePasswordChange()) {
      return;
    }

    final bool passwordChanged = controller.passwordSectionHasInput;

    await showCustomerFeedbackPopup(
      context: context,
      title: passwordChanged ? 'تم تغيير كلمة المرور' : 'تم تحديث البيانات',
      message: passwordChanged
          ? 'تم تغيير كلمة المرور'
          : 'تم تحديث البيانات الشخصية',
      icon: passwordChanged
          ? Icons.lock_reset_rounded
          : Icons.verified_user_rounded,
      iconStartColor: passwordChanged
          ? const Color(0xFFC47A3D)
          : const Color(0xFF22C55E),
      iconEndColor: passwordChanged
          ? const Color(0xFFF6D38B)
          : const Color(0xFF86EFAC),
    );

    if (!mounted) return;

    Navigator.of(context).pop(controller.buildResult());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final Color pageBg = Theme.of(context).scaffoldBackgroundColor;
        final Color titleColor = AppThemeColors.textPrimary(context);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: pageBg,
            appBar: AppBar(
              title: const SizedBox.shrink(),
              centerTitle: true,
              backgroundColor: pageBg,
              surfaceTintColor: pageBg,
              elevation: 0,
              iconTheme: IconThemeData(color: titleColor),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    const CustomerProfileIntroCard(),

                    const SizedBox(height: 16),

                    CustomerProfileFormBox(
                      hasProfileImage: controller.hasProfileImage,
                      nameController: controller.nameController,
                      phoneController: controller.phoneController,
                      selectedCountry: controller.selectedCountry,
                      phoneCode: controller.phoneCode,
                      onCountryChanged: controller.changeCountry,
                      onAddOrChangeImage: _addOrChangeImage,
                      onRemoveImage: _removeImage,
                    ),

                    const SizedBox(height: 16),

                    CustomerPasswordBox(
                      currentPasswordController:
                          controller.currentPasswordController,
                      newPasswordController: controller.newPasswordController,
                      confirmPasswordController:
                          controller.confirmPasswordController,
                      showCurrentPassword: controller.showCurrentPassword,
                      showNewPassword: controller.showNewPassword,
                      showConfirmPassword: controller.showConfirmPassword,
                      onToggleCurrent:
                          controller.toggleCurrentPasswordVisibility,
                      onToggleNew: controller.toggleNewPasswordVisibility,
                      onToggleConfirm:
                          controller.toggleConfirmPasswordVisibility,
                      currentPasswordError: controller.currentPasswordError,
                      newPasswordError: controller.newPasswordError,
                      confirmPasswordError: controller.confirmPasswordError,
                      currentPasswordShakeTrigger:
                          controller.currentPasswordShakeTrigger,
                      newPasswordShakeTrigger:
                          controller.newPasswordShakeTrigger,
                      confirmPasswordShakeTrigger:
                          controller.confirmPasswordShakeTrigger,
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: CustomerProfilePrimarySaveButton(
                        label: 'حفظ التغييرات',
                        icon: Icons.save_rounded,
                        onTap: controller.hasUnsavedChanges ? save : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
