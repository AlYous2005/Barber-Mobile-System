import '../auth.dart';

export '../models/auth_exception.dart';

class AuthService {
  const AuthService({
    this.authRepository = const AuthSupabaseRepository(),
    this.profileRepository = const AuthProfileRepository(),
    this.barberRepository = const AuthBarberRepository(),
  });

  final AuthSupabaseRepository authRepository;
  final AuthProfileRepository profileRepository;
  final AuthBarberRepository barberRepository;

  Future<AppUser> login({
    required String username,
    required String password,
    required String role,
    String? signedUpCustomerDisplayName,
  }) async {
    final input = validateLoginInput(username: username, password: password);

    try {
      final authResponse = await authRepository.signInWithPhonePassword(
        phone: normalizePhoneForAuth(input.username),
        password: input.password,
      );

      final supabaseUser = authResponse.user;

      if (supabaseUser == null) {
        throw const AuthException('تعذر تسجيل الدخول، حاول مرة أخرى');
      }

      final profileRow = await profileRepository.getProfileByUserId(
        supabaseUser.id,
      );

      if (profileRow == null) {
        throw const AuthException(AuthErrorMessages.missingProfile);
      }

      final profileRole = readTextFromRow(profileRow, 'role');

      if (profileRole != role) {
        await authRepository.signOut();

        if (role == AuthRoles.barber) {
          throw const AuthException(AuthErrorMessages.notBarberAccount);
        }

        throw const AuthException(AuthErrorMessages.notCustomerAccount);
      }

      String? barberId;

      if (profileRole == AuthRoles.barber) {
        barberId = await barberRepository.getBarberIdByProfileId(
          supabaseUser.id,
        );

        if (barberId == null) {
          await authRepository.signOut();
          throw const AuthException(AuthErrorMessages.missingBarberRecord);
        }
      }

      return mapProfileRowToAppUser(
        userId: supabaseUser.id,
        profileRow: profileRow,
        barberId: barberId,
      );
    } catch (error) {
      throw mapLoginError(error);
    }
  }

  Future<PendingPhoneSignUp> signUpCustomer({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required DateTime? birthDate,
    required String? areaId,
  }) async {
    final input = validateCustomerSignUpInput(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      birthDate: birthDate,
      areaId: areaId,
    );

    try {
      final normalizedPhoneNumber = normalizePhoneForAuth(input.phoneNumber);

      final phoneAlreadyExists = await profileRepository.phoneExists(
        normalizedPhoneNumber,
      );

      if (phoneAlreadyExists) {
        throw const AuthException(AuthErrorMessages.phoneAlreadyUsed);
      }

      await authRepository.signUpWithPhonePassword(
        phone: normalizedPhoneNumber,
        password: input.password,
        data: {
          AuthMetadataKeys.firstName: input.firstName,
          AuthMetadataKeys.lastName: input.lastName,
          AuthMetadataKeys.phoneNumber: normalizedPhoneNumber,
          AuthMetadataKeys.role: AuthRoles.customer,
          AuthMetadataKeys.birthDate: formatDateForDatabase(input.birthDate),
          AuthMetadataKeys.areaId: input.areaId,
        },
      );

      return PendingPhoneSignUp(
        phoneNumber: normalizedPhoneNumber,
        firstName: input.firstName,
        lastName: input.lastName,
        birthDate: input.birthDate,
        role: AuthRoles.customer,
        areaId: input.areaId,
      );
    } catch (error) {
      throw mapSignUpError(error);
    }
  }

  Future<AppUser> verifyCustomerPhoneSignUp({
    required PendingPhoneSignUp pendingSignUp,
    required String otpCode,
  }) async {
    final input = validateOtpInput(otpCode);

    try {
      final authResponse = await authRepository.verifySmsOtp(
        phone: pendingSignUp.phoneNumber,
        token: input.otpCode,
      );

      final supabaseUser = authResponse.user;

      if (supabaseUser == null) {
        throw const AuthException('تعذر تأكيد رقم الهاتف، حاول مرة أخرى');
      }

      await profileRepository.upsertCustomerProfile(
        userId: supabaseUser.id,
        firstName: pendingSignUp.firstName,
        lastName: pendingSignUp.lastName,
        phoneNumber: pendingSignUp.phoneNumber,
        birthDate: formatDateForDatabase(pendingSignUp.birthDate),
        role: pendingSignUp.role,
        areaId: pendingSignUp.areaId,
      );

      await profileRepository.markPhoneAsVerified(supabaseUser.id);

      return AppUser(
        username: supabaseUser.id,
        displayName: pendingSignUp.displayName,
        role: pendingSignUp.role,
        firstName: pendingSignUp.firstName,
        lastName: pendingSignUp.lastName,
        phoneNumber: pendingSignUp.phoneNumber,
        birthDate: pendingSignUp.birthDate,
        areaId: pendingSignUp.areaId,
      );
    } catch (error) {
      throw mapVerifyPhoneSignUpError(error);
    }
  }

  Future<void> sendPasswordResetOtp({required String phoneNumber}) async {
    final normalizedPhone = normalizePhoneForAuth(phoneNumber);

    try {
      await authRepository.sendPasswordResetOtp(normalizedPhone);
    } catch (error) {
      throw mapSendPasswordResetOtpError(error);
    }
  }

  Future<void> verifyPasswordResetOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final normalizedPhone = normalizePhoneForAuth(phoneNumber);
    final input = validateOtpInput(otpCode);

    try {
      await authRepository.verifySmsOtp(
        phone: normalizedPhone,
        token: input.otpCode,
      );
    } catch (error) {
      throw mapVerifyPasswordResetOtpError(error);
    }
  }

  Future<void> updateForgottenPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final input = validateForgottenPasswordInput(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    try {
      await authRepository.updatePassword(input.password);

      await authRepository.signOut();
    } catch (error) {
      throw mapForgottenPasswordUpdateError(error);
    }
  }

  Future<void> updateCurrentUserPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final input = validateCurrentPasswordChangeInput(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    final currentAuthUser = authRepository.currentUser;

    if (currentAuthUser == null) {
      throw const AuthException(AuthErrorMessages.missingCurrentUser);
    }

    final phone = currentAuthUser.phone;

    if (phone == null || phone.trim().isEmpty) {
      throw const AuthException(AuthErrorMessages.missingUserPhone);
    }

    try {
      await authRepository.signInWithPhonePassword(
        phone: normalizePhoneForAuth(phone),
        password: input.currentPassword,
      );

      await authRepository.updatePassword(input.newPassword);
    } catch (error) {
      throw mapCurrentPasswordUpdateError(error);
    }
  }
}
