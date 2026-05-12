import '../../../services/supabase_config.dart';
import '../constants/auth_constants.dart';

class AuthProfileRepository {
  const AuthProfileRepository();

  Future<Map<String, dynamic>?> getProfileByUserId(String userId) {
    return SupabaseConfig.client
        .from('profiles')
        .select(
          '${ProfileColumnNames.firstName}, '
          '${ProfileColumnNames.lastName}, '
          '${ProfileColumnNames.phoneNumber}, '
          '${ProfileColumnNames.role}, '
          '${ProfileColumnNames.birthDate}, '
          '${ProfileColumnNames.avatarUrl}, '
          '${ProfileColumnNames.areaId}',
        )
        .eq(ProfileColumnNames.id, userId)
        .maybeSingle();
  }

  Future<bool> phoneExists(String phoneNumber) async {
    final existingProfile = await SupabaseConfig.client
        .from('profiles')
        .select(ProfileColumnNames.id)
        .eq(ProfileColumnNames.phoneNumber, phoneNumber)
        .maybeSingle();

    return existingProfile != null;
  }

  Future<void> upsertCustomerProfile({
    required String userId,
    required String areaId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String birthDate,
    required String role,
  }) async {
    await SupabaseConfig.client.from('profiles').upsert({
      ProfileColumnNames.id: userId,
      ProfileColumnNames.firstName: firstName,
      ProfileColumnNames.lastName: lastName,
      ProfileColumnNames.phoneNumber: phoneNumber,
      ProfileColumnNames.role: role,
      ProfileColumnNames.birthDate: birthDate,
      ProfileColumnNames.areaId: areaId,
    });
  }

  Future<void> markPhoneAsVerified(String userId) async {
    await SupabaseConfig.client
        .from('profiles')
        .update({
          ProfileColumnNames.phoneVerified: true,
          ProfileColumnNames.phoneVerifiedAt: DateTime.now()
              .toUtc()
              .toIso8601String(),
        })
        .eq(ProfileColumnNames.id, userId);
  }
}
