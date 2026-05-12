import '../models/auth_exception.dart';
import '../utils/auth_error_messages.dart';
import 'password_validator.dart';

class ValidatedLoginInput {
  const ValidatedLoginInput({required this.username, required this.password});

  final String username;
  final String password;
}

class ValidatedCustomerSignUpInput {
  const ValidatedCustomerSignUpInput({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.birthDate,
    required this.areaId,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final DateTime birthDate;
  final String areaId;
}

class ValidatedOtpInput {
  const ValidatedOtpInput({required this.otpCode});

  final String otpCode;
}

class ValidatedForgottenPasswordInput {
  const ValidatedForgottenPasswordInput({
    required this.password,
    required this.confirmPassword,
  });

  final String password;
  final String confirmPassword;
}

class ValidatedCurrentPasswordChangeInput {
  const ValidatedCurrentPasswordChangeInput({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
}

ValidatedLoginInput validateLoginInput({
  required String username,
  required String password,
}) {
  final trimmedUsername = username.trim();
  final trimmedPassword = password.trim();

  if (trimmedUsername.isEmpty && trimmedPassword.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterLoginCredentials);
  }

  if (trimmedUsername.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterLoginIdentifier);
  }

  if (trimmedPassword.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterPassword);
  }

  return ValidatedLoginInput(
    username: trimmedUsername,
    password: trimmedPassword,
  );
}

ValidatedCustomerSignUpInput validateCustomerSignUpInput({
  required String firstName,
  required String lastName,
  required String phoneNumber,
  required String password,
  required String confirmPassword,
  required DateTime? birthDate,
  required String? areaId,
}) {
  final trimmedFirstName = firstName.trim();
  final trimmedLastName = lastName.trim();
  final trimmedPhoneNumber = phoneNumber.trim();
  final trimmedPassword = password.trim();
  final trimmedConfirmPassword = confirmPassword.trim();
  final trimmedAreaId = areaId?.trim() ?? '';

  if (trimmedFirstName.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterFirstName);
  }

  if (trimmedLastName.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterLastName);
  }

  if (trimmedPhoneNumber.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterPhone);
  }

  if (birthDate == null) {
    throw const AuthException(AuthErrorMessages.chooseBirthDate);
  }
  if (trimmedAreaId.isEmpty) {
    throw const AuthException('الرجاء اختيار منطقتك');
  }

  final passwordValidation = validateNewPassword(
    password: trimmedPassword,
    confirmPassword: trimmedConfirmPassword,
  );

  if (!passwordValidation.isValid) {
    throw AuthException(passwordValidation.message!);
  }

  return ValidatedCustomerSignUpInput(
    firstName: trimmedFirstName,
    lastName: trimmedLastName,
    phoneNumber: trimmedPhoneNumber,
    password: trimmedPassword,
    confirmPassword: trimmedConfirmPassword,
    birthDate: birthDate,
    areaId: trimmedAreaId,
  );
}

ValidatedOtpInput validateOtpInput(String otpCode) {
  final trimmedOtpCode = otpCode.trim();

  if (trimmedOtpCode.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterOtp);
  }

  return ValidatedOtpInput(otpCode: trimmedOtpCode);
}

ValidatedForgottenPasswordInput validateForgottenPasswordInput({
  required String newPassword,
  required String confirmPassword,
}) {
  final trimmedPassword = newPassword.trim();
  final trimmedConfirmPassword = confirmPassword.trim();

  final passwordValidation = validateNewPassword(
    password: trimmedPassword,
    confirmPassword: trimmedConfirmPassword,
    passwordEmptyMessage: 'الرجاء إدخال كلمة المرور الجديدة',
    confirmPasswordEmptyMessage: 'الرجاء تأكيد كلمة المرور الجديدة',
  );

  if (!passwordValidation.isValid) {
    throw AuthException(passwordValidation.message!);
  }

  return ValidatedForgottenPasswordInput(
    password: trimmedPassword,
    confirmPassword: trimmedConfirmPassword,
  );
}

ValidatedCurrentPasswordChangeInput validateCurrentPasswordChangeInput({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) {
  final trimmedCurrentPassword = currentPassword.trim();
  final trimmedNewPassword = newPassword.trim();
  final trimmedConfirmPassword = confirmPassword.trim();

  if (trimmedCurrentPassword.isEmpty) {
    throw const AuthException(AuthErrorMessages.enterCurrentPassword);
  }

  final passwordValidation = validateNewPassword(
    password: trimmedNewPassword,
    confirmPassword: trimmedConfirmPassword,
    passwordEmptyMessage: 'الرجاء إدخال كلمة المرور الجديدة',
    minLengthMessage: 'كلمة المرور الجديدة يجب أن تكون 8 خانات على الأقل',
    numberMessage: 'كلمة المرور الجديدة يجب أن تحتوي على رقم واحد على الأقل',
    symbolMessage: 'كلمة المرور الجديدة يجب أن تحتوي على رمز واحد على الأقل',
    confirmPasswordEmptyMessage: 'الرجاء تأكيد كلمة المرور الجديدة',
  );

  if (!passwordValidation.isValid) {
    throw AuthException(passwordValidation.message!);
  }

  if (trimmedCurrentPassword == trimmedNewPassword) {
    throw const AuthException(AuthErrorMessages.samePasswordShort);
  }

  return ValidatedCurrentPasswordChangeInput(
    currentPassword: trimmedCurrentPassword,
    newPassword: trimmedNewPassword,
    confirmPassword: trimmedConfirmPassword,
  );
}
