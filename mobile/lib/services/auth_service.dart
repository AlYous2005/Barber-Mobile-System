import '../models/app_user.dart';

class AuthService {
  const AuthService();

  Future<AppUser> login({
    required String username,
    required String password,
    required String role,
    String? signedUpCustomerDisplayName,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty && trimmedPassword.isEmpty) {
      throw const AuthException('الرجاء إدخال اسم المستخدم وكلمة المرور');
    }

    if (trimmedUsername.isEmpty) {
      throw const AuthException('الرجاء إدخال اسم المستخدم');
    }

    if (trimmedPassword.isEmpty) {
      throw const AuthException('الرجاء إدخال كلمة المرور');
    }

    // تأخير بسيط لمحاكاة الاتصال بالسيرفر.
    // لاحقًا لما نربط Backend حقيقي، هذا المكان سيتحول إلى API call.
    await Future.delayed(const Duration(milliseconds: 650));

    if (role == 'barber') {
      if (trimmedUsername != 'admin') {
        throw const AuthException('هذا الحساب غير موجود');
      }

      if (trimmedPassword != '1234') {
        throw const AuthException('كلمة المرور خطأ');
      }

      return AppUser(
        username: trimmedUsername,
        displayName: 'أحمد',
        role: 'barber',
        barberId: 'b1',
      );
    }

    if (trimmedUsername != 'customer') {
      throw const AuthException('هذا الحساب غير موجود');
    }

    if (trimmedPassword != '1234') {
      throw const AuthException('كلمة المرور خطأ');
    }

    final displayName =
        signedUpCustomerDisplayName != null &&
            signedUpCustomerDisplayName.trim().isNotEmpty
        ? signedUpCustomerDisplayName.trim()
        : '';

    final nameParts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    return AppUser(
      username: trimmedUsername,
      displayName: displayName,
      role: 'customer',
      firstName: nameParts.isNotEmpty ? nameParts.first : null,
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
    );
  }

  Future<AppUser> signUpCustomer({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required DateTime? birthDate,
  }) async {
    final trimmedFirstName = firstName.trim();
    final trimmedLastName = lastName.trim();
    final trimmedPhoneNumber = phoneNumber.trim();
    final trimmedPassword = password.trim();
    final trimmedConfirmPassword = confirmPassword.trim();

    if (trimmedFirstName.isEmpty) {
      throw const AuthException('الرجاء إدخال الاسم الأول');
    }

    if (trimmedLastName.isEmpty) {
      throw const AuthException('الرجاء إدخال اسم العائلة');
    }

    if (trimmedPhoneNumber.isEmpty) {
      throw const AuthException('الرجاء إدخال رقم الهاتف');
    }

    if (birthDate == null) {
      throw const AuthException('الرجاء اختيار تاريخ الميلاد');
    }

    if (trimmedPassword.isEmpty) {
      throw const AuthException('الرجاء إدخال كلمة المرور');
    }

    if (trimmedPassword.length < 8) {
      throw const AuthException('كلمة المرور يجب أن تكون 8 خانات على الأقل');
    }

    if (!RegExp(r'[0-9]').hasMatch(trimmedPassword)) {
      throw const AuthException(
        'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل',
      );
    }

    if (!RegExp(
      r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\[\];]',
    ).hasMatch(trimmedPassword)) {
      throw const AuthException(
        'كلمة المرور يجب أن تحتوي على رمز واحد على الأقل',
      );
    }

    if (trimmedConfirmPassword.isEmpty) {
      throw const AuthException('الرجاء تأكيد كلمة المرور');
    }

    if (trimmedPassword != trimmedConfirmPassword) {
      throw const AuthException('كلمتا المرور غير متطابقتين');
    }

    await Future.delayed(const Duration(milliseconds: 650));

    final displayName = '$trimmedFirstName $trimmedLastName';

    return AppUser(
      username: trimmedPhoneNumber,
      displayName: displayName,
      role: 'customer',
      firstName: trimmedFirstName,
      lastName: trimmedLastName,
      phoneNumber: trimmedPhoneNumber,
      birthDate: birthDate,
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
