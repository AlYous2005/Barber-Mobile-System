import '../../../services/supabase_config.dart';
import '../models/area_model.dart';
import '../models/governorate_model.dart';

class LocationRepository {
  const LocationRepository();

  Future<List<GovernorateModel>> getActiveGovernorates() async {
    final List<dynamic> rows = await SupabaseConfig.client
        .from('governorates')
        .select('id, name_ar')
        .eq('is_active', true)
        .order('name_ar');

    return rows
        .whereType<Map<String, dynamic>>()
        .map(GovernorateModel.fromMap)
        .toList();
  }

  Future<List<AreaModel>> getActiveAreasByGovernorate({
    required String governorateId,
  }) async {
    final String cleanGovernorateId = governorateId.trim();

    if (cleanGovernorateId.isEmpty) {
      return <AreaModel>[];
    }

    final List<dynamic> rows = await SupabaseConfig.client
        .from('areas')
        .select('id, governorate_id, name_ar')
        .eq('is_active', true)
        .eq('governorate_id', cleanGovernorateId)
        .order('name_ar');

    return rows
        .whereType<Map<String, dynamic>>()
        .map(AreaModel.fromMap)
        .toList();
  }
}
