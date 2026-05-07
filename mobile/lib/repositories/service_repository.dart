import '../models/service_model.dart';
import '../models/ui_service_model.dart';
import '../services/supabase_config.dart';
import 'contracts/service_repository_contract.dart';

class ServiceRepository implements ServiceRepositoryContract {
  const ServiceRepository();

  @override
  Future<List<ServiceModel>> getAvailableServices({
    required String barberId,
  }) async {
    final rows = await SupabaseConfig.client
        .from('barber_services')
        .select('id, name, duration_minutes, price')
        .eq('barber_id', barberId)
        .eq('is_active', true)
        .filter('archived_at', 'is', null)
        .order('name');

    return rows.map<ServiceModel>((row) {
      return ServiceModel(
        id: row['id'].toString(),
        name: (row['name'] ?? '').toString(),
        durationMinutes: _parseInt(row['duration_minutes']),
        price: _parseInt(row['price']),
      );
    }).toList();
  }

  @override
  Future<List<UiService>> getBarberServices({required String barberId}) async {
    final rows = await SupabaseConfig.client
        .from('barber_services')
        .select('id, name, duration_minutes, price, is_active')
        .eq('barber_id', barberId)
        .filter('archived_at', 'is', null)
        .order('name');

    return rows.map<UiService>((row) {
      return UiService(
        id: row['id'].toString(),
        name: (row['name'] ?? '').toString(),
        price: _parseDouble(row['price']),
        durationMinutes: _parseInt(row['duration_minutes']),
        isActive: row['is_active'] == true,
      );
    }).toList();
  }

  @override
  Future<UiService> addBarberService({
    required String barberId,
    required UiService service,
  }) async {
    final row = await SupabaseConfig.client
        .from('barber_services')
        .insert({
          'barber_id': barberId,
          'name': service.name.trim(),
          'duration_minutes': service.durationMinutes,
          'price': service.price,
          'is_active': service.isActive,
        })
        .select('id, name, duration_minutes, price, is_active')
        .single();

    return UiService(
      id: row['id'].toString(),
      name: (row['name'] ?? '').toString(),
      price: _parseDouble(row['price']),
      durationMinutes: _parseInt(row['duration_minutes']),
      isActive: row['is_active'] == true,
    );
  }

  @override
  Future<UiService> updateBarberService({
    required String barberId,
    required UiService service,
  }) async {
    final row = await SupabaseConfig.client
        .from('barber_services')
        .update({
          'name': service.name.trim(),
          'duration_minutes': service.durationMinutes,
          'price': service.price,
          'is_active': service.isActive,
        })
        .eq('id', service.id)
        .eq('barber_id', barberId)
        .select('id, name, duration_minutes, price, is_active')
        .single();

    return UiService(
      id: row['id'].toString(),
      name: (row['name'] ?? '').toString(),
      price: _parseDouble(row['price']),
      durationMinutes: _parseInt(row['duration_minutes']),
      isActive: row['is_active'] == true,
    );
  }

  @override
  Future<UiService> setServiceActive({
    required String barberId,
    required String serviceId,
    required bool isActive,
  }) async {
    final row = await SupabaseConfig.client
        .from('barber_services')
        .update({'is_active': isActive})
        .eq('id', serviceId)
        .eq('barber_id', barberId)
        .select('id, name, duration_minutes, price, is_active')
        .single();

    return UiService(
      id: row['id'].toString(),
      name: (row['name'] ?? '').toString(),
      price: _parseDouble(row['price']),
      durationMinutes: _parseInt(row['duration_minutes']),
      isActive: row['is_active'] == true,
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}

double _parseDouble(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}
