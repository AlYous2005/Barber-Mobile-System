import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_config.dart';

class AuthSupabaseRepository {
  const AuthSupabaseRepository();

  Future<AuthResponse> signInWithPhonePassword({
    required String phone,
    required String password,
  }) {
    return SupabaseConfig.client.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithPhonePassword({
    required String phone,
    required String password,
    required Map<String, dynamic> data,
  }) {
    return SupabaseConfig.client.auth.signUp(
      phone: phone,
      password: password,
      channel: OtpChannel.sms,
      data: data,
    );
  }

  Future<AuthResponse> verifySmsOtp({
    required String phone,
    required String token,
  }) {
    return SupabaseConfig.client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> sendPasswordResetOtp(String phone) {
    return SupabaseConfig.client.auth.signInWithOtp(
      phone: phone,
      shouldCreateUser: false,
      channel: OtpChannel.sms,
    );
  }

  Future<void> updatePassword(String password) {
    return SupabaseConfig.client.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  Future<void> signOut() {
    return SupabaseConfig.client.auth.signOut();
  }

  User? get currentUser => SupabaseConfig.client.auth.currentUser;
}
