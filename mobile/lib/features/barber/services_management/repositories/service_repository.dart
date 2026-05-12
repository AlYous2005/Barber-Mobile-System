import '../models/service_model.dart';
import '../models/service_target.dart';
import '../models/ui_service_model.dart';
import '../../../../services/supabase_config.dart';

import 'contracts/service_repository_contract.dart';

class ServiceRepository implements ServiceRepositoryContract {
  const ServiceRepository();

  static const _serviceSelectColumns =
      'id, name, duration_minutes, price, is_active, service_target, service_image_url, service_icon_key';

  static const _availableServiceSelectColumns =
      'id, name, duration_minutes, price, service_target, service_image_url, service_icon_key';

  @override
  Future<List<ServiceModel>> getAvailableServices({
    required String barberId,
  }) async {
    final rows = await SupabaseConfig.client
        .from('barber_services')
        .select(_availableServiceSelectColumns)
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
        target: ServiceTargetX.fromDatabaseValue(
          row['service_target']?.toString(),
        ),
        serviceImageUrl: _parseNullableString(row['service_image_url']),
        serviceIconKey: _parseNullableString(row['service_icon_key']),
      );
    }).toList();
  }

  @override
  Future<List<UiService>> getBarberServices({required String barberId}) async {
    final rows = await SupabaseConfig.client
        .from('barber_services')
        .select(_serviceSelectColumns)
        .eq('barber_id', barberId)
        .filter('archived_at', 'is', null)
        .order('name');

    return rows.map<UiService>(_mapUiService).toList();
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
          'service_target': service.target.databaseValue,
          'is_active': service.isActive,
          'service_image_url': service.serviceImageUrl,
          'service_icon_key': service.serviceIconKey,
        })
        .select(_serviceSelectColumns)
        .single();

    return _mapUiService(row);
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
          'service_target': service.target.databaseValue,
          'is_active': service.isActive,
          'service_image_url': service.serviceImageUrl,
          'service_icon_key': service.serviceIconKey,
        })
        .eq('id', service.id)
        .eq('barber_id', barberId)
        .select(_serviceSelectColumns)
        .single();

    return _mapUiService(row);
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
        .select(_serviceSelectColumns)
        .single();

    return _mapUiService(row);
  }

  @override
  Future<void> archiveBarberService({
    required String barberId,
    required String serviceId,
  }) async {
    await SupabaseConfig.client
        .from('barber_services')
        .update(<String, dynamic>{
          'archived_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', serviceId)
        .eq('barber_id', barberId);
  }

  UiService _mapUiService(Map<String, dynamic> row) {
    return UiService(
      id: row['id'].toString(),
      name: (row['name'] ?? '').toString(),
      price: _parseDouble(row['price']),
      durationMinutes: _parseInt(row['duration_minutes']),
      target: ServiceTargetX.fromDatabaseValue(
        row['service_target']?.toString(),
      ),
      isActive: row['is_active'] == true,
      serviceImageUrl: _parseNullableString(row['service_image_url']),
      serviceIconKey: _parseNullableString(row['service_icon_key']),
    );
  }

  String? _parseNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    return text;
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
