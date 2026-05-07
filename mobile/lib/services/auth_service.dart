import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/pending_phone_signup.dart';
import 'supabase_config.dart';

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
      throw const AuthException(
        'الرجاء إدخال البريد الإلكتروني أو رقم الهاتف وكلمة المرور',
      );
    }

    if (trimmedUsername.isEmpty) {
      throw const AuthException('الرجاء إدخال البريد الإلكتروني أو رقم الهاتف');
    }

    if (trimmedPassword.isEmpty) {
      throw const AuthException('الرجاء إدخال كلمة المرور');
    }

    try {
      final authResponse = await SupabaseConfig.client.auth.signInWithPassword(
        phone: _normalizePhoneForAuth(trimmedUsername),
        password: trimmedPassword,
      );

      final supabaseUser = authResponse.user;

      if (supabaseUser == null) {
        throw const AuthException('تعذر تسجيل الدخول، حاول مرة أخرى');
      }

      final profileRow = await SupabaseConfig.client
          .from('profiles')
          .select('first_name, last_name, phone_number, role, birth_date')
          .eq('id', supabaseUser.id)
          .maybeSingle();

      if (profileRow == null) {
        throw const AuthException('لا يوجد ملف شخصي مرتبط بهذا الحساب');
      }

      final profileRole = (profileRow['role'] ?? '').toString();

      if (profileRole != role) {
        await SupabaseConfig.client.auth.signOut();

        if (role == 'barber') {
          throw const AuthException('هذا الحساب ليس حساب حلاق');
        }

        throw const AuthException('هذا الحساب ليس حساب زبون');
      }

      final firstName = (profileRow['first_name'] ?? '').toString().trim();
      final lastName = (profileRow['last_name'] ?? '').toString().trim();
      final phoneNumber = (profileRow['phone_number'] ?? '').toString().trim();
      final birthDate = _parseDate(profileRow['birth_date']);

      String? barberId;

      if (profileRole == 'barber') {
        final barberRow = await SupabaseConfig.client
            .from('barbers')
            .select('id')
            .eq('profile_id', supabaseUser.id)
            .maybeSingle();

        if (barberRow == null) {
          await SupabaseConfig.client.auth.signOut();
          throw const AuthException('لا يوجد سجل حلاق مرتبط بهذا الحساب');
        }

        barberId = barberRow['id'].toString();
      }

      final displayName = '$firstName $lastName'.trim();

      return AppUser(
        username: supabaseUser.id,
        displayName: displayName,
        role: profileRole,
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
        phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
        birthDate: birthDate,
        barberId: barberId,
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('بيانات الدخول غير صحيحة أو حدث خطأ بالاتصال');
    }
  }

  Future<PendingPhoneSignUp> signUpCustomer({
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

    try {
      final normalizedPhoneNumber = _normalizePhoneForAuth(trimmedPhoneNumber);

      await SupabaseConfig.client.auth.signUp(
        phone: normalizedPhoneNumber,
        password: trimmedPassword,
        channel: OtpChannel.sms,
        data: {
          'first_name': trimmedFirstName,
          'last_name': trimmedLastName,
          'phone_number': normalizedPhoneNumber,
          'role': 'customer',
          'birth_date': _formatDate(birthDate),
        },
      );

      return PendingPhoneSignUp(
        phoneNumber: normalizedPhoneNumber,
        firstName: trimmedFirstName,
        lastName: trimmedLastName,
        birthDate: birthDate,
        role: 'customer',
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException('تعذر إنشاء الحساب أو إرسال رمز التحقق: $error');
    }
  }

  String _normalizePhoneForAuth(String phoneNumber) {
    final trimmed = phoneNumber.trim();

    if (trimmed.startsWith('+')) {
      return trimmed.replaceAll(RegExp(r'\s+'), '');
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.startsWith('970')) {
      return '+$digitsOnly';
    }

    if (digitsOnly.startsWith('972')) {
      return '+$digitsOnly';
    }

    if (digitsOnly.startsWith('0')) {
      return '+970${digitsOnly.substring(1)}';
    }

    return '+970$digitsOnly';
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<AppUser> verifyCustomerPhoneSignUp({
    required PendingPhoneSignUp pendingSignUp,
    required String otpCode,
  }) async {
    final trimmedOtpCode = otpCode.trim();

    if (trimmedOtpCode.isEmpty) {
      throw const AuthException('الرجاء إدخال رمز التحقق');
    }

    try {
      final authResponse = await SupabaseConfig.client.auth.verifyOTP(
        phone: pendingSignUp.phoneNumber,
        token: trimmedOtpCode,
        type: OtpType.sms,
      );

      final supabaseUser = authResponse.user;

      if (supabaseUser == null) {
        throw const AuthException('تعذر تأكيد رقم الهاتف، حاول مرة أخرى');
      }

      await SupabaseConfig.client.from('profiles').upsert({
        'id': supabaseUser.id,
        'first_name': pendingSignUp.firstName,
        'last_name': pendingSignUp.lastName,
        'phone_number': pendingSignUp.phoneNumber,
        'role': pendingSignUp.role,
        'birth_date': _formatDate(pendingSignUp.birthDate),
      });

      await SupabaseConfig.client
          .from('profiles')
          .update({
            'phone_verified': true,
            'phone_verified_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', supabaseUser.id);

      return AppUser(
        username: supabaseUser.id,
        displayName: pendingSignUp.displayName,
        role: pendingSignUp.role,
        firstName: pendingSignUp.firstName,
        lastName: pendingSignUp.lastName,
        phoneNumber: pendingSignUp.phoneNumber,
        birthDate: pendingSignUp.birthDate,
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException('رمز التحقق غير صحيح أو انتهت صلاحيته: $error');
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
