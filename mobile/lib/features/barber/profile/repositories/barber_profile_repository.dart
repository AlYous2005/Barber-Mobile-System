import '../../../../services/supabase_config.dart';

class BarberProfileData {
  const BarberProfileData({
    required this.name,
    required this.phone,
    required this.whatsappPhone,
    required this.address,
    required this.bio,
    required this.areaId,
    required this.areaName,
    required this.governorateId,
    required this.governorateName,
  });

  final String name;
  final String phone;
  final String whatsappPhone;
  final String address;
  final String bio;
  final String areaId;
  final String areaName;
  final String governorateId;
  final String governorateName;

  String get locationLabel {
    if (governorateName.isNotEmpty && areaName.isNotEmpty) {
      return '$governorateName - $areaName';
    }

    if (areaName.isNotEmpty) {
      return areaName;
    }

    if (governorateName.isNotEmpty) {
      return governorateName;
    }

    return '';
  }
}

class BarberProfileRepository {
  const BarberProfileRepository();

  Future<BarberProfileData?> getProfile({required String barberId}) async {
    final cleanedBarberId = barberId.trim();
    if (cleanedBarberId.isEmpty) {
      return null;
    }

    final row = await SupabaseConfig.client
        .from('barbers')
        .select(
          'name, phone, whatsapp_phone, address, bio, area_id, '
          'areas(name_ar, governorate_id, governorates(name_ar))',
        )
        .eq('id', cleanedBarberId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    final areaRow = row['areas'];
    final Map<String, dynamic>? areaMap = areaRow is Map<String, dynamic>
        ? areaRow
        : null;

    final governorateRow = areaMap?['governorates'];
    final Map<String, dynamic>? governorateMap =
        governorateRow is Map<String, dynamic> ? governorateRow : null;

    return BarberProfileData(
      name: _clean(row['name']),
      phone: _clean(row['phone']),
      whatsappPhone: _clean(row['whatsapp_phone']),
      address: _clean(row['address']),
      bio: _clean(row['bio']),
      areaId: _clean(row['area_id']),
      areaName: _clean(areaMap?['name_ar']),
      governorateId: _clean(areaMap?['governorate_id']),
      governorateName: _clean(governorateMap?['name_ar']),
    );
  }

  Future<void> updateProfile({
    required String barberId,
    required String name,
    required String phone,
    required String whatsappPhone,
    required String address,
    required String bio,
    required String areaId,
  }) async {
    final cleanedBarberId = barberId.trim();
    if (cleanedBarberId.isEmpty) {
      throw StateError('Missing barber id');
    }

    await SupabaseConfig.client
        .from('barbers')
        .update({
          'name': name.trim(),
          'phone': phone.trim().isEmpty ? null : phone.trim(),
          'whatsapp_phone': whatsappPhone.trim().isEmpty
              ? null
              : whatsappPhone.trim(),
          'address': address.trim().isEmpty ? null : address.trim(),
          'bio': bio.trim().isEmpty ? null : bio.trim(),
          'area_id': areaId.trim().isEmpty ? null : areaId.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', cleanedBarberId);
  }

  static String _clean(dynamic value) {
    return (value ?? '').toString().trim();
  }
}
