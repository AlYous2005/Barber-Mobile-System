import '../models/auth_exception.dart';
import 'auth_error_messages.dart';

AuthException mapLoginError(Object error) {
  if (error is AuthException) {
    return error;
  }

  return const AuthException(AuthErrorMessages.loginFailed);
}

AuthException mapSignUpError(Object error) {
  if (error is AuthException) {
    return error;
  }

  return AuthException('تعذر إنشاء الحساب أو إرسال رمز التحقق: $error');
}

AuthException mapVerifyPhoneSignUpError(Object error) {
  if (error is AuthException) {
    return error;
  }

  return AuthException('رمز التحقق غير صحيح أو انتهت صلاحيته: $error');
}

AuthException mapSendPasswordResetOtpError(Object error) {
  if (error is AuthException) {
    return error;
  }

  return AuthException('تعذر إرسال رمز التحقق: $error');
}

AuthException mapVerifyPasswordResetOtpError(Object error) {
  if (error is AuthException) {
    return error;
  }

  return AuthException('رمز التحقق غير صحيح أو انتهت صلاحيته: $error');
}

AuthException mapForgottenPasswordUpdateError(Object error) {
  if (error is AuthException) {
    return error;
  }

  final errorText = error.toString();

  if (errorText.contains('same_password') ||
      errorText.contains('New password should be different')) {
    return const AuthException(AuthErrorMessages.samePassword);
  }

  return const AuthException(
    'تعذر تحديث كلمة المرور، تأكد من الرمز وحاول مرة أخرى',
  );
}

AuthException mapCurrentPasswordUpdateError(Object error) {
  if (error is AuthException) {
    return error;
  }

  final errorText = error.toString().toLowerCase();

  if (errorText.contains('invalid login credentials')) {
    return const AuthException(AuthErrorMessages.wrongCurrentPassword);
  }

  if (errorText.contains('same_password') ||
      errorText.contains('new password should be different')) {
    return const AuthException(AuthErrorMessages.samePassword);
  }

  return const AuthException(AuthErrorMessages.changePasswordRetry);
}
