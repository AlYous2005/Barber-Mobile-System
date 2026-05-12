import '../../../../services/supabase_config.dart';

/// Reads/writes barber booking window columns on `barbers`.
class BarberBookingWindowRepository {
  const BarberBookingWindowRepository();

  Future<({bool enabled, String type})?> fetchForBarber({
    required String barberId,
  }) async {
    final String id = barberId.trim();
    if (id.isEmpty) {
      return null;
    }

    final Map<String, dynamic>? row = await SupabaseConfig.client
        .from('barbers')
        .select('booking_window_enabled, booking_window_type')
        .eq('id', id)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    final bool enabled = row['booking_window_enabled'] == true;
    final String type =
        (row['booking_window_type'] ?? 'month').toString().trim();

    return (enabled: enabled, type: type.isEmpty ? 'month' : type);
  }

  Future<void> updateForBarber({
    required String barberId,
    required bool enabled,
    required String bookingWindowType,
  }) async {
    final String id = barberId.trim();
    if (id.isEmpty) {
      throw StateError('معرف الحلاق غير صالح');
    }

    await SupabaseConfig.client.from('barbers').update(<String, dynamic>{
      'booking_window_enabled': enabled,
      'booking_window_type': bookingWindowType,
    }).eq('id', id);
  }
}
