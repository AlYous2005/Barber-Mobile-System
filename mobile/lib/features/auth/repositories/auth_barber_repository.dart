import '../../../services/supabase_config.dart';
import '../constants/auth_constants.dart';

class AuthBarberRepository {
  const AuthBarberRepository();

  Future<String?> getBarberIdByProfileId(String profileId) async {
    final barberRow = await SupabaseConfig.client
        .from('barbers')
        .select(BarberColumnNames.id)
        .eq(BarberColumnNames.profileId, profileId)
        .maybeSingle();

    return barberRow?[BarberColumnNames.id]?.toString();
  }
}
