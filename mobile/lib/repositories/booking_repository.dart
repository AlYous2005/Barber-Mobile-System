import '../models/booking_model.dart';
import '../models/mock_appointment.dart';
import '../services/supabase_config.dart';
import '../utils/booking_formatters.dart';
import 'contracts/booking_repository_contract.dart';
import '../models/selected_booking_service.dart';
import '../models/service_target.dart';

class BookingRepository implements BookingRepositoryContract {
  const BookingRepository();

  String _mapArabicStatusToDatabase(String status) {
    switch (status) {
      case 'معلق':
      case 'معلقة':
        return 'pending';
      case 'مؤكد':
      case 'مؤكدة':
      case 'تم التأكيد':
      case 'قادم':
        return 'confirmed';
      case 'مكتمل':
      case 'مكتملة':
        return 'completed';
      case 'ملغي':
      case 'ملغية':
        return 'cancelled';
      case 'لم يحضر':
        return 'no_show';
      default:
        return status;
    }
  }

  @override
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    await SupabaseConfig.client
        .from('appointments')
        .update({'status': _mapArabicStatusToDatabase(status)})
        .eq('id', appointmentId);
  }

  DateTime _parseCreatedAt(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) {
      return DateTime.now();
    }

    return parsed.toLocal();
  }

  @override
  Future<List<MockAppointment>> getCustomerAppointments({
    required String customerId,
  }) async {
    final rows = await SupabaseConfig.client
        .from('appointments')
        .select()
        .eq('customer_id', customerId)
        .order('appointment_date')
        .order('start_time');

    final List<MockAppointment> appointments = [];

    for (final row in rows) {
      appointments.add(await _mapAppointmentRow(row));
    }

    return appointments;
  }

  @override
  Future<List<MockAppointment>> getBarberAppointments({
    required String barberId,
  }) async {
    final rows = await SupabaseConfig.client
        .from('appointments')
        .select()
        .eq('barber_id', barberId)
        .order('appointment_date')
        .order('start_time');

    final List<MockAppointment> appointments = [];

    for (final row in rows) {
      appointments.add(await _mapAppointmentRow(row));
    }

    return appointments;
  }

  @override
  Future<BookingModel> createBooking({
    required BookingModel booking,
    required List<SelectedBookingService> selectedServices,
    required String customerId,
    required String customerName,
  }) async {
    final DateTime startDateTime = _resolveAppointmentStartDateTime(
      booking.date,
      booking.timeLabel,
    );

    final int totalDuration = selectedServices.fold(
      0,
      (sum, selected) => sum + selected.durationMinutes,
    );

    final int totalPrice = selectedServices.fold(
      0,
      (sum, selected) => sum + selected.price,
    );

    final DateTime endDateTime = startDateTime.add(
      Duration(minutes: totalDuration),
    );

    final appointmentRow = await SupabaseConfig.client
        .from('appointments')
        .insert({
          'customer_id': customerId,
          'barber_id': booking.barber.id,
          'appointment_date': _formatDate(startDateTime),
          'start_time': _formatTime(startDateTime),
          'end_time': _formatTime(endDateTime),
          'status': 'pending',
          'total_price': totalPrice,
          'total_duration_minutes': totalDuration,
          'checked_in': false,
          'reminder_sent': false,
          'no_show_marked': false,
        })
        .select('id')
        .single();

    final String appointmentId = appointmentRow['id'].toString();

    final serviceRows = selectedServices.map((selected) {
      return {
        'appointment_id': appointmentId,
        'service_id': selected.service.id,
        'service_name_snapshot': selected.service.name,
        'price_snapshot': selected.price,
        'duration_minutes_snapshot': selected.durationMinutes,
        'service_target': selected.target.databaseValue,
      };
    }).toList();

    await SupabaseConfig.client
        .from('appointment_services')
        .insert(serviceRows);

    return booking;
  }

  Future<MockAppointment> _mapAppointmentRow(Map<String, dynamic> row) async {
    final String appointmentId = row['id'].toString();
    final String customerId = row['customer_id'].toString();
    final String barberId = row['barber_id'].toString();

    final customerRow = await SupabaseConfig.client
        .from('profiles')
        .select('first_name, last_name, phone_number, avatar_url')
        .eq('id', customerId)
        .maybeSingle();

    final barberRow = await SupabaseConfig.client
        .from('barbers')
        .select('name, rating')
        .eq('id', barberId)
        .maybeSingle();

    final serviceRows = await SupabaseConfig.client
        .from('appointment_services')
        .select('service_name_snapshot')
        .eq('appointment_id', appointmentId)
        .order('created_at');

    final DateTime startDateTime = _combineDateAndTime(
      row['appointment_date'],
      row['start_time'],
    );

    final DateTime endDateTime = _combineDateAndTime(
      row['appointment_date'],
      row['end_time'],
    );

    final String customerName = _buildCustomerName(customerRow);
    final String barberName = (barberRow?['name'] ?? '').toString();
    final double barberRating = _parseDouble(barberRow?['rating']);

    final String serviceName = serviceRows
        .map((serviceRow) {
          return (serviceRow['service_name_snapshot'] ?? '').toString();
        })
        .where((name) => name.trim().isNotEmpty)
        .join(' - ');

    return MockAppointment(
      id: appointmentId,
      customerId: customerId,
      barberId: barberId,
      customerName: customerName,
      customerAvatarUrl: _cleanNullableText(
        customerRow?['avatar_url']?.toString(),
      ),
      customerPhoneNumber: _cleanNullableText(
        customerRow?['phone_number']?.toString(),
      ),
      barberName: barberName,
      barberRating: barberRating,
      serviceName: serviceName.isEmpty ? 'خدمة غير محددة' : serviceName,
      dateLabel: _formatDateLabel(startDateTime),
      timeLabel: formatArabicAppointmentTimeRange(startDateTime, endDateTime),
      status: _mapStatusToArabic((row['status'] ?? '').toString()),
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      createdAt: _parseCreatedAt(row['created_at']),
    );
  }

  DateTime _resolveAppointmentStartDateTime(DateTime date, String timeLabel) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeLabel);

    if (match == null) {
      return date;
    }

    int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);

    final bool isMorning = timeLabel.contains('صباح');
    final bool isNoon = timeLabel.contains('ظهر');
    final bool isEvening = timeLabel.contains('مساء');

    if (isMorning && hour == 12) {
      hour = 0;
    }

    if ((isEvening || isNoon) && hour != 12) {
      hour += 12;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime _combineDateAndTime(dynamic dateValue, dynamic timeValue) {
    final String date = dateValue.toString();
    final String time = timeValue.toString();

    return DateTime.parse('${date}T$time');
  }

  String _formatDate(DateTime dateTime) {
    final String year = dateTime.year.toString().padLeft(4, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  String _formatDateLabel(DateTime dateTime) {
    final DateTime now = DateTime.now();

    final bool isToday =
        dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    final DateTime tomorrow = now.add(const Duration(days: 1));

    final bool isTomorrow =
        dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;

    if (isToday) {
      return 'اليوم';
    }

    if (isTomorrow) {
      return 'غدًا';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _buildCustomerName(Map<String, dynamic>? row) {
    if (row == null) {
      return 'زبون';
    }

    final String firstName = (row['first_name'] ?? '').toString().trim();
    final String lastName = (row['last_name'] ?? '').toString().trim();

    final String fullName = '$firstName $lastName'.trim();

    return fullName.isEmpty ? 'زبون' : fullName;
  }

  String _mapStatusToArabic(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      case 'no_show':
        return 'لم يحضر';
      default:
        return status;
    }
  }

  String? _cleanNullableText(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
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
}
