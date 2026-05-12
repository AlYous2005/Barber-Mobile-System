// UI + popups + navigation
import 'package:flutter/material.dart';

import '../../controllers/customer/customer_profile_controller.dart';
import '../../general_utils/app_theme_colors.dart';
import '../../widgets/customer/profile/customer_password_box.dart';
import '../../widgets/customer/profile/customer_profile_form_box.dart';
import '../../widgets/customer/profile/customer_profile_intro_card.dart';
import '../../widgets/customer/profile/customer_profile_shared_widgets.dart';
import '../../widgets/customer/shared/customer_feedback_popup.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/customer/profile/customer_profile.dart';
import '../../features/auth/auth.dart';
import '../../services/auth_session.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    required this.initialDisplayName,
    required this.initialCountryCode,
    required this.initialPhoneNumber,
    this.initialAvatarUrl,
  });

  final String initialDisplayName;
  final String initialCountryCode;
  final String initialPhoneNumber;
  final String? initialAvatarUrl;
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late final CustomerProfileController controller;
  final ImagePicker _imagePicker = ImagePicker();
  final CustomerProfileRepository _profileRepository =
      const CustomerProfileRepository();
  final AuthService _authService = const AuthService();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    controller = CustomerProfileController(
      initialDisplayName: widget.initialDisplayName,
      initialCountryCode: widget.initialCountryCode,
      initialPhoneNumber: widget.initialPhoneNumber,
      initialAvatarUrl: widget.initialAvatarUrl,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _addOrChangeImage() async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );

      if (selectedImage == null) {
        return;
      }

      controller.setUploadingImage(true);

      final imageBytes = await selectedImage.readAsBytes();

      final avatarUrl = await _profileRepository.uploadCustomerAvatar(
        userId: currentUser.username,
        imageBytes: imageBytes,
        originalFileName: selectedImage.name,
      );

      controller.setAvatarUrl(avatarUrl);

      AuthSession.updateCurrentUser(currentUser.copyWith(avatarUrl: avatarUrl));

      if (!mounted) return;

      await showCustomerFeedbackPopup(
        context: context,
        title: 'تم تحديث الصورة',
        message: 'تم رفع صورة البروفايل وحفظها بنجاح',
        icon: Icons.image_rounded,
      );
    } catch (error) {
      if (!mounted) return;

      await showCustomerFeedbackPopup(
        context: context,
        title: 'فشل رفع الصورة',
        message: 'تأكد من اتصال الإنترنت وحاول مرة أخرى',
        icon: Icons.error_outline_rounded,
        iconStartColor: const Color(0xFFEF4444),
        iconEndColor: const Color(0xFFFCA5A5),
      );
    } finally {
      controller.setUploadingImage(false);
    }
  }

  Future<void> _removeImage() async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      await _profileRepository.removeCustomerAvatar(
        userId: currentUser.username,
      );

      controller.setAvatarUrl(null);

      AuthSession.updateCurrentUser(currentUser.copyWith(avatarUrl: null));

      if (!mounted) return;

      await showCustomerFeedbackPopup(
        context: context,
        title: 'تم إزالة الصورة',
        message: 'تم إزالة الصورة بنجاح',
        icon: Icons.delete_outline_rounded,
        iconStartColor: const Color(0xFFEF4444),
        iconEndColor: const Color(0xFFFCA5A5),
      );
    } catch (error) {
      if (!mounted) return;

      await showCustomerFeedbackPopup(
        context: context,
        title: 'فشل حذف الصورة',
        message: 'حاول مرة أخرى',
        icon: Icons.error_outline_rounded,
        iconStartColor: const Color(0xFFEF4444),
        iconEndColor: const Color(0xFFFCA5A5),
      );
    }
  }

  Future<void> save() async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

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

    setState(() {
      isSaving = true;
    });

    try {
      await _profileRepository.updateCustomerProfile(
        userId: currentUser.username,
        displayName: name,
        phoneNumber: controller.internationalPhoneNumber,
      );

      final bool passwordChanged = controller.passwordSectionHasInput;

      if (passwordChanged) {
        await _authService.updateCurrentUserPassword(
          currentPassword: controller.currentPasswordController.text,
          newPassword: controller.newPasswordController.text,
          confirmPassword: controller.confirmPasswordController.text,
        );

        controller.clearPasswordFields();
      }

      final result = controller.buildResult();

      final nameParts = result.displayName
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      AuthSession.updateCurrentUser(
        currentUser.copyWith(
          displayName: result.displayName,
          firstName: nameParts.isNotEmpty
              ? nameParts.first
              : currentUser.firstName,
          lastName: nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : currentUser.lastName,
          phoneNumber: controller.internationalPhoneNumber,
          avatarUrl: result.avatarUrl,
        ),
      );

      if (!mounted) return;

      await showCustomerFeedbackPopup(
        context: context,
        title: passwordChanged ? 'تم تغيير كلمة المرور' : 'تم تحديث البيانات',
        message: passwordChanged
            ? 'تم تغيير كلمة المرور بنجاح'
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

      Navigator.of(context).pop(result);
    } catch (error) {
      final message = error.toString();

      if (message.contains('كلمة المرور الحالية')) {
        controller.setPasswordError('كلمة المرور الحالية غير صحيحة');
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
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
                      avatarUrl: controller.avatarUrl,
                      isUploadingImage: controller.isUploadingImage,
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
                        label: isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
                        icon: Icons.save_rounded,
                        onTap: controller.hasUnsavedChanges && !isSaving
                            ? save
                            : null,
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
