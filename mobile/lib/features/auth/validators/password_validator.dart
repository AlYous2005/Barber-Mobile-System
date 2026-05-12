class PasswordValidationResult {
  const PasswordValidationResult._({required this.isValid, this.message});

  final bool isValid;
  final String? message;

  const PasswordValidationResult.valid() : this._(isValid: true);

  const PasswordValidationResult.invalid(String message)
    : this._(isValid: false, message: message);
}

PasswordValidationResult validateNewPassword({
  required String password,
  required String confirmPassword,
  String passwordEmptyMessage = 'الرجاء إدخال كلمة المرور',
  String confirmPasswordEmptyMessage = 'الرجاء تأكيد كلمة المرور',
  String minLengthMessage = 'كلمة المرور يجب أن تكون 8 خانات على الأقل',
  String numberMessage = 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل',
  String symbolMessage = 'كلمة المرور يجب أن تحتوي على رمز واحد على الأقل',
  String mismatchMessage = 'كلمتا المرور غير متطابقتين',
}) {
  final trimmedPassword = password.trim();
  final trimmedConfirmPassword = confirmPassword.trim();

  if (trimmedPassword.isEmpty) {
    return PasswordValidationResult.invalid(passwordEmptyMessage);
  }

  if (trimmedPassword.length < 8) {
    return PasswordValidationResult.invalid(minLengthMessage);
  }

  if (!RegExp(r'[0-9]').hasMatch(trimmedPassword)) {
    return PasswordValidationResult.invalid(numberMessage);
  }

  if (!RegExp(
    r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\[\];]',
  ).hasMatch(trimmedPassword)) {
    return PasswordValidationResult.invalid(symbolMessage);
  }

  if (trimmedConfirmPassword.isEmpty) {
    return PasswordValidationResult.invalid(confirmPasswordEmptyMessage);
  }

  if (trimmedPassword != trimmedConfirmPassword) {
    return PasswordValidationResult.invalid(mismatchMessage);
  }

  return const PasswordValidationResult.valid();
}
