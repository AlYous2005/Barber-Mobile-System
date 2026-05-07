import '../models/barber_model.dart';
import '../services/supabase_config.dart';
import 'contracts/barber_repository_contract.dart';

class BarberRepository implements BarberRepositoryContract {
  const BarberRepository();

  @override
  Future<List<BarberModel>> getAvailableBarbers() async {
    final rows = await SupabaseConfig.client
        .from('barbers')
        .select(
          'id, profile_id, salon_id, name, shop_name, phone, address, bio, rating, salon_image_url',
        )
        .eq('is_active', true)
        .order('name');

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);

    return rows.map<BarberModel>((row) {
      return _mapBarberRow(row, avatarUrlsByProfileId: avatarUrlsByProfileId);
    }).toList();
  }

  Future<List<BarberModel>> getBarbersBySalonId({
    required String salonId,
  }) async {
    final cleanedSalonId = salonId.trim();

    if (cleanedSalonId.isEmpty) {
      return [];
    }

    final rows = await SupabaseConfig.client
        .from('barbers')
        .select(
          'id, profile_id, salon_id, name, shop_name, phone, address, bio, rating, salon_image_url',
        )
        .eq('salon_id', cleanedSalonId)
        .eq('is_active', true)
        .order('name');

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);

    return rows.map<BarberModel>((row) {
      return _mapBarberRow(row, avatarUrlsByProfileId: avatarUrlsByProfileId);
    }).toList();
  }

  @override
  Future<BarberModel?> findBarberByName(String barberName) async {
    final normalizedName = barberName.trim();

    if (normalizedName.isEmpty) {
      return null;
    }

    final rows = await SupabaseConfig.client
        .from('barbers')
        .select(
          'id, profile_id, salon_id, name, shop_name, phone, address, bio, rating, salon_image_url',
        )
        .eq('is_active', true)
        .eq('name', normalizedName)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);

    return _mapBarberRow(
      rows.first,
      avatarUrlsByProfileId: avatarUrlsByProfileId,
    );
  }

  Future<Map<String, String>> _loadAvatarUrlsByProfileId(
    List<dynamic> barberRows,
  ) async {
    final profileIds = barberRows
        .map((row) => row['profile_id']?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (profileIds.isEmpty) {
      return {};
    }

    final profileRows = await SupabaseConfig.client
        .from('profiles')
        .select('id, avatar_url')
        .inFilter('id', profileIds);

    final Map<String, String> avatarUrlsByProfileId = {};

    for (final row in profileRows) {
      final profileId = row['id']?.toString();
      final avatarUrl = row['avatar_url']?.toString().trim();

      if (profileId == null ||
          profileId.isEmpty ||
          avatarUrl == null ||
          avatarUrl.isEmpty) {
        continue;
      }

      avatarUrlsByProfileId[profileId] = avatarUrl;
    }

    return avatarUrlsByProfileId;
  }

  BarberModel _mapBarberRow(
    Map<String, dynamic> row, {
    required Map<String, String> avatarUrlsByProfileId,
  }) {
    final profileId = row['profile_id']?.toString();
    final salonImageUrl = row['salon_image_url']?.toString().trim();
    final barberAvatarUrl = profileId == null
        ? null
        : avatarUrlsByProfileId[profileId];

    return BarberModel(
      id: row['id'].toString(),
      name: (row['name'] ?? '').toString(),
      shopName: (row['shop_name'] ?? '').toString(),
      distance: 'غير محدد',
      rating: _parseRating(row['rating']),
      salonId: _cleanNullableText(row['salon_id']?.toString()),
      salonImageUrl: _cleanNullableText(salonImageUrl),
      barberAvatarUrl: _cleanNullableText(barberAvatarUrl),
      phone: _cleanNullableText(row['phone']?.toString()),
      address: _cleanNullableText(row['address']?.toString()),
      bio: _cleanNullableText(row['bio']?.toString()),
    );
  }

  String? _cleanNullableText(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  double _parseRating(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
