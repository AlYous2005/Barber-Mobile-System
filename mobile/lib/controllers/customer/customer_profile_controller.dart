// TextEditingControllers + form state + validation + result building

import 'package:flutter/material.dart';

import '../../models/customer_profile_result.dart';

class CustomerProfileController extends ChangeNotifier {
  CustomerProfileController({
    required this.initialDisplayName,
    required this.initialCountryCode,
    required this.initialPhoneNumber,
    required this.initialHasProfileImage,
  }) {
    nameController = TextEditingController(text: initialDisplayName);
    phoneController = TextEditingController(text: initialPhoneNumber);
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    selectedCountry = initialCountryCode == '+972' ? 'إسرائيل' : 'فلسطين';
    hasProfileImage = initialHasProfileImage;

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

  /// TEMPORARY: replace with real auth / API check when backend is integrated.
  static const String _mockCurrentPassword = '123456';

  final String initialDisplayName;
  final String initialCountryCode;
  final String initialPhoneNumber;
  final bool initialHasProfileImage;

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

  String get phoneCode {
    return selectedCountry == 'فلسطين' ? '+970' : '+972';
  }

  bool get hasUnsavedChanges {
    final String currentName = nameController.text.trim();
    final String initialName = initialDisplayName.trim();

    final String currentPhone = phoneController.text.trim();
    final String initialPhone = initialPhoneNumber.trim();

    return currentName != initialName ||
        currentPhone != initialPhone ||
        phoneCode != initialCountryCode ||
        hasProfileImage != initialHasProfileImage ||
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

  void setHasProfileImage(bool value) {
    hasProfileImage = value;
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

    final String currentPassword = currentPasswordController.text.trim();
    final String newPassword = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    String? currentError;
    String? newError;
    String? confirmError;

    if (currentPassword.isEmpty) {
      currentError = 'أدخل كلمة المرور الحالية';
    } else if (currentPassword != _mockCurrentPassword) {
      currentError = 'كلمة المرور الحالية غير صحيحة';
    }

    if (newPassword.isEmpty) {
      newError = 'أدخل كلمة المرور الجديدة';
    } else if (newPassword.length < 6) {
      newError = 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل';
    }

    if (confirmPassword.isEmpty) {
      confirmError = 'أكد كلمة المرور الجديدة';
    } else if (newPassword.isNotEmpty &&
        newPassword.length >= 6 &&
        newPassword != confirmPassword) {
      confirmError = 'كلمة السر غير متطابقة';
    }

    final bool isValid =
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

  CustomerProfileResult buildResult() {
    return CustomerProfileResult(
      displayName: nameController.text.trim(),
      countryCode: phoneCode,
      phoneNumber: phoneController.text.trim(),
      hasProfileImage: hasProfileImage,
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
