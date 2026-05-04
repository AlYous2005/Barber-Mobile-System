import 'package:flutter/material.dart';

import '../../models/customer_profile_result.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/customer/profile/customer_profile_intro_card.dart';
import '../../widgets/customer/profile/customer_profile_shared_widgets.dart';
import '../../widgets/customer/profile/customer_password_box.dart';
import '../../widgets/customer/profile/customer_profile_form_box.dart';
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
  /// TEMPORARY: replace with real auth / API check when backend is integrated.
  static const String _mockCurrentPassword = '123456';

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  late final VoidCallback _onCurrentPasswordEdited;
  late final VoidCallback _onNewPasswordEdited;
  late final VoidCallback _onConfirmPasswordEdited;

  String selectedCountry = 'فلسطين';
  bool hasProfileImage = false;

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  String? currentPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  int currentPasswordShakeTrigger = 0;
  int newPasswordShakeTrigger = 0;
  int confirmPasswordShakeTrigger = 0;

  String get phoneCode => selectedCountry == 'فلسطين' ? '+970' : '+972';

  bool get _hasUnsavedChanges {
    final String currentName = nameController.text.trim();
    final String initialName = widget.initialDisplayName.trim();

    final String currentPhone = phoneController.text.trim();
    final String initialPhone = widget.initialPhoneNumber.trim();

    return currentName != initialName ||
        currentPhone != initialPhone ||
        phoneCode != widget.initialCountryCode ||
        hasProfileImage != widget.initialHasProfileImage ||
        _passwordSectionHasInput();
  }

  void _refreshSaveButtonState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialDisplayName);
    phoneController = TextEditingController(text: widget.initialPhoneNumber);
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    nameController.addListener(_refreshSaveButtonState);
    phoneController.addListener(_refreshSaveButtonState);

    _onCurrentPasswordEdited = () {
      if (!mounted) return;
      setState(() {
        currentPasswordError = null;
      });
    };
    _onNewPasswordEdited = () {
      if (!mounted) return;
      setState(() {
        newPasswordError = null;
      });
    };
    _onConfirmPasswordEdited = () {
      if (!mounted) return;
      setState(() {
        confirmPasswordError = null;
      });
    };

    currentPasswordController.addListener(_onCurrentPasswordEdited);
    newPasswordController.addListener(_onNewPasswordEdited);
    confirmPasswordController.addListener(_onConfirmPasswordEdited);

    selectedCountry = widget.initialCountryCode == '+972'
        ? 'إسرائيل'
        : 'فلسطين';
    hasProfileImage = widget.initialHasProfileImage;
  }

  @override
  void dispose() {
    nameController.removeListener(_refreshSaveButtonState);
    phoneController.removeListener(_refreshSaveButtonState);
    currentPasswordController.removeListener(_onCurrentPasswordEdited);
    newPasswordController.removeListener(_onNewPasswordEdited);
    confirmPasswordController.removeListener(_onConfirmPasswordEdited);

    nameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _addOrChangeImage() async {
    final bool alreadyHadImage = hasProfileImage;

    setState(() {
      hasProfileImage = true;
    });

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
    setState(() {
      hasProfileImage = false;
    });

    await showCustomerFeedbackPopup(
      context: context,
      title: 'تم إزالة الصورة',
      message: 'تم إزالة الصورة بنجاح',
      icon: Icons.delete_outline_rounded,
      iconStartColor: const Color(0xFFEF4444),
      iconEndColor: const Color(0xFFFCA5A5),
    );
  }

  bool _passwordSectionHasInput() {
    return currentPasswordController.text.trim().isNotEmpty ||
        newPasswordController.text.trim().isNotEmpty ||
        confirmPasswordController.text.trim().isNotEmpty;
  }

  /// Returns `true` if password area is unused or all password rules pass.
  bool _validatePasswordChange() {
    if (!_passwordSectionHasInput()) {
      setState(() {
        currentPasswordError = null;
        newPasswordError = null;
        confirmPasswordError = null;
      });
      return true;
    }

    final String c = currentPasswordController.text.trim();
    final String n = newPasswordController.text.trim();
    final String cf = confirmPasswordController.text.trim();

    String? curE;
    String? newE;
    String? confE;

    if (c.isEmpty) {
      curE = 'أدخل كلمة المرور الحالية';
    } else if (c != _mockCurrentPassword) {
      curE = 'كلمة المرور الحالية غير صحيحة';
    }

    if (n.isEmpty) {
      newE = 'أدخل كلمة المرور الجديدة';
    } else if (n.length < 6) {
      newE = 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل';
    }

    if (cf.isEmpty) {
      confE = 'أكد كلمة المرور الجديدة';
    } else if (n.isNotEmpty && n.length >= 6 && n != cf) {
      confE = 'كلمة السر غير متطابقة';
    }

    final bool ok = curE == null && newE == null && confE == null;

    if (!ok) {
      setState(() {
        currentPasswordError = curE;
        newPasswordError = newE;
        confirmPasswordError = confE;
        if (curE != null) currentPasswordShakeTrigger++;
        if (newE != null) newPasswordShakeTrigger++;
        if (confE != null) confirmPasswordShakeTrigger++;
      });
      return false;
    }

    setState(() {
      currentPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
    });
    return true;
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

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

    if (!_validatePasswordChange()) {
      return;
    }

    final bool passwordChanged = _passwordSectionHasInput();

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

    Navigator.of(context).pop(
      CustomerProfileResult(
        displayName: name,
        countryCode: phoneCode,
        phoneNumber: phone,
        hasProfileImage: hasProfileImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  hasProfileImage: hasProfileImage,
                  nameController: nameController,
                  phoneController: phoneController,
                  selectedCountry: selectedCountry,
                  phoneCode: phoneCode,
                  onCountryChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedCountry = value;
                    });
                  },
                  onAddOrChangeImage: _addOrChangeImage,
                  onRemoveImage: _removeImage,
                ),

                const SizedBox(height: 16),

                CustomerPasswordBox(
                  currentPasswordController: currentPasswordController,
                  newPasswordController: newPasswordController,
                  confirmPasswordController: confirmPasswordController,
                  showCurrentPassword: showCurrentPassword,
                  showNewPassword: showNewPassword,
                  showConfirmPassword: showConfirmPassword,
                  onToggleCurrent: () {
                    setState(() {
                      showCurrentPassword = !showCurrentPassword;
                    });
                  },
                  onToggleNew: () {
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                  onToggleConfirm: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                  currentPasswordError: currentPasswordError,
                  newPasswordError: newPasswordError,
                  confirmPasswordError: confirmPasswordError,
                  currentPasswordShakeTrigger: currentPasswordShakeTrigger,
                  newPasswordShakeTrigger: newPasswordShakeTrigger,
                  confirmPasswordShakeTrigger: confirmPasswordShakeTrigger,
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: CustomerProfilePrimarySaveButton(
                    label: 'حفظ التغييرات',
                    icon: Icons.save_rounded,
                    onTap: _hasUnsavedChanges ? save : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
