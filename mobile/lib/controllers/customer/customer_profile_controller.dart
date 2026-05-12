import 'package:flutter/material.dart';

import '../../features/customer/profile/customer_profile.dart';

class CustomerProfileController extends ChangeNotifier {
  CustomerProfileController({
    required this.initialDisplayName,
    required this.initialCountryCode,
    required this.initialPhoneNumber,
    required this.initialAvatarUrl,
  }) {
    nameController = TextEditingController(text: initialDisplayName);
    phoneController = TextEditingController(text: initialPhoneNumber);
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    selectedCountry = initialCountryCode == '+972' ? 'إسرائيل' : 'فلسطين';
    avatarUrl = initialAvatarUrl;

    nameController.addListener(_refreshState);
    phoneController.addListener(_refreshState);

    _onCurrentPasswordEdited = () {
      currentPasswordError = null;
      notifyListeners();
    };

    _onNewPasswordEdited = () {
      newPasswordError = null;
      notifyListeners();
    };

    _onConfirmPasswordEdited = () {
      confirmPasswordError = null;
      notifyListeners();
    };

    currentPasswordController.addListener(_onCurrentPasswordEdited);
    newPasswordController.addListener(_onNewPasswordEdited);
    confirmPasswordController.addListener(_onConfirmPasswordEdited);
  }

  final String initialDisplayName;
  final String initialCountryCode;
  final String initialPhoneNumber;
  final String? initialAvatarUrl;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  late final VoidCallback _onCurrentPasswordEdited;
  late final VoidCallback _onNewPasswordEdited;
  late final VoidCallback _onConfirmPasswordEdited;

  String selectedCountry = 'فلسطين';
  String? avatarUrl;

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool isUploadingImage = false;

  String? currentPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  int currentPasswordShakeTrigger = 0;
  int newPasswordShakeTrigger = 0;
  int confirmPasswordShakeTrigger = 0;

  String get phoneCode {
    return selectedCountry == 'فلسطين' ? '+970' : '+972';
  }

  bool get hasProfileImage {
    return avatarUrl != null && avatarUrl!.trim().isNotEmpty;
  }

  String get internationalPhoneNumber {
    final rawPhone = phoneController.text.trim();

    if (rawPhone.startsWith('+')) {
      return rawPhone.replaceAll(RegExp(r'\s+'), '');
    }

    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.startsWith('970') || digitsOnly.startsWith('972')) {
      return '+$digitsOnly';
    }

    final normalizedLocalNumber = digitsOnly.startsWith('0')
        ? digitsOnly.substring(1)
        : digitsOnly;

    return '$phoneCode$normalizedLocalNumber';
  }

  bool get hasUnsavedChanges {
    final currentName = nameController.text.trim();
    final initialName = initialDisplayName.trim();

    final currentPhone = phoneController.text.trim();
    final initialPhone = initialPhoneNumber.trim();

    final currentInitialAvatar = initialAvatarUrl?.trim() ?? '';
    final currentAvatar = avatarUrl?.trim() ?? '';

    return currentName != initialName ||
        currentPhone != initialPhone ||
        phoneCode != initialCountryCode ||
        currentAvatar != currentInitialAvatar ||
        passwordSectionHasInput;
  }

  bool get passwordSectionHasInput {
    return currentPasswordController.text.trim().isNotEmpty ||
        newPasswordController.text.trim().isNotEmpty ||
        confirmPasswordController.text.trim().isNotEmpty;
  }

  void _refreshState() {
    notifyListeners();
  }

  void changeCountry(String? value) {
    if (value == null) return;

    selectedCountry = value;
    notifyListeners();
  }

  void setAvatarUrl(String? value) {
    avatarUrl = value;
    notifyListeners();
  }

  void setUploadingImage(bool value) {
    isUploadingImage = value;
    notifyListeners();
  }

  void toggleCurrentPasswordVisibility() {
    showCurrentPassword = !showCurrentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    showNewPassword = !showNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword = !showConfirmPassword;
    notifyListeners();
  }

  bool validatePasswordChange() {
    if (!passwordSectionHasInput) {
      currentPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
      notifyListeners();
      return true;
    }

    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    String? currentError;
    String? newError;
    String? confirmError;

    if (currentPassword.isEmpty) {
      currentError = 'أدخل كلمة المرور الحالية';
    }

    if (newPassword.isEmpty) {
      newError = 'أدخل كلمة المرور الجديدة';
    } else if (newPassword.length < 8) {
      newError = 'كلمة المرور الجديدة يجب أن تكون 8 خانات على الأقل';
    } else if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      newError = 'كلمة المرور الجديدة يجب أن تحتوي على رقم';
    } else if (!RegExp(
      r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\[\];]',
    ).hasMatch(newPassword)) {
      newError = 'كلمة المرور الجديدة يجب أن تحتوي على رمز';
    }

    if (confirmPassword.isEmpty) {
      confirmError = 'أكد كلمة المرور الجديدة';
    } else if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      confirmError = 'كلمة المرور غير متطابقة';
    }

    final isValid =
        currentError == null && newError == null && confirmError == null;

    currentPasswordError = currentError;
    newPasswordError = newError;
    confirmPasswordError = confirmError;

    if (!isValid) {
      if (currentError != null) currentPasswordShakeTrigger++;
      if (newError != null) newPasswordShakeTrigger++;
      if (confirmError != null) confirmPasswordShakeTrigger++;
    }

    notifyListeners();

    return isValid;
  }

  void setPasswordError(String message) {
    currentPasswordError = message;
    currentPasswordShakeTrigger++;
    notifyListeners();
  }

  void clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  CustomerProfileResult buildResult() {
    return CustomerProfileResult(
      displayName: nameController.text.trim(),
      countryCode: phoneCode,
      phoneNumber: phoneController.text.trim(),
      avatarUrl: avatarUrl,
    );
  }

  @override
  void dispose() {
    nameController.removeListener(_refreshState);
    phoneController.removeListener(_refreshState);

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
}
