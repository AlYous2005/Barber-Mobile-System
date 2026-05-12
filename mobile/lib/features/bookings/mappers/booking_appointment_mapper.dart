import '../models/appointment_cancelled_by.dart';
import '../models/mock_appointment.dart';
import '../../../services/supabase_config.dart';
import '../constants/booking_constants.dart';
import '../utils/booking_datetime_helper.dart';
import '../utils/booking_status_mapper.dart';
import '../../barber/services_management/services_management.dart';

class BookingAppointmentMapper {
  const BookingAppointmentMapper();

  Future<MockAppointment> mapAppointmentRow(Map<String, dynamic> row) async {
    final List<MockAppointment> mapped = await mapAppointmentRows([row]);
    return mapped.first;
  }

  Future<List<MockAppointment>> mapAppointmentRows(List<dynamic> rows) async {
    if (rows.isEmpty) {
      return <MockAppointment>[];
    }

    final Set<String> customerIds = <String>{};
    final Set<String> barberIds = <String>{};
    final Set<String> appointmentIds = <String>{};

    for (final dynamic item in rows) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final String? appointmentId = _cleanNullableText(
        item[AppointmentColumnNames.id]?.toString(),
      );

      final String? customerId = _cleanNullableText(
        item[AppointmentColumnNames.customerId]?.toString(),
      );

      final String? barberId = _cleanNullableText(
        item[AppointmentColumnNames.barberId]?.toString(),
      );

      if (appointmentId != null) {
        appointmentIds.add(appointmentId);
      }

      if (customerId != null) {
        customerIds.add(customerId);
      }

      if (barberId != null) {
        barberIds.add(barberId);
      }
    }

    final Map<String, Map<String, dynamic>> customersById =
        await _loadCustomersById(customerIds);

    final Map<String, Map<String, dynamic>> barbersById =
        await _loadBarbersById(barberIds);

    final Map<String, List<Map<String, dynamic>>> servicesByAppointmentId =
        await _loadServicesByAppointmentId(appointmentIds);

    final List<MockAppointment> appointments = <MockAppointment>[];

    for (final dynamic item in rows) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      appointments.add(
        _mapAppointmentRowFromCachedData(
          row: item,
          customersById: customersById,
          barbersById: barbersById,
          servicesByAppointmentId: servicesByAppointmentId,
        ),
      );
    }

    return appointments;
  }

  Future<Map<String, Map<String, dynamic>>> _loadCustomersById(
    Set<String> customerIds,
  ) async {
    if (customerIds.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }

    final List<dynamic> rows = await SupabaseConfig.client
        .from(BookingTableNames.profiles)
        .select(
          '${BookingProfileColumnNames.firstName}, '
          '${BookingProfileColumnNames.lastName}, '
          '${BookingProfileColumnNames.phoneNumber}, '
          '${BookingProfileColumnNames.avatarUrl}, '
          '${AppointmentColumnNames.id}',
        )
        .inFilter(AppointmentColumnNames.id, customerIds.toList());

    final Map<String, Map<String, dynamic>> result =
        <String, Map<String, dynamic>>{};

    for (final dynamic row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }

      final String? id = _cleanNullableText(
        row[AppointmentColumnNames.id]?.toString(),
      );

      if (id != null) {
        result[id] = row;
      }
    }

    return result;
  }

  Future<Map<String, Map<String, dynamic>>> _loadBarbersById(
    Set<String> barberIds,
  ) async {
    if (barberIds.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }

    final List<dynamic> rows = await SupabaseConfig.client
        .from(BookingTableNames.barbers)
        .select(
          '${BookingBarberColumnNames.id}, '
          '${BookingBarberColumnNames.name}, '
          '${BookingBarberColumnNames.rating}',
        )
        .inFilter(BookingBarberColumnNames.id, barberIds.toList());

    final Map<String, Map<String, dynamic>> result =
        <String, Map<String, dynamic>>{};

    for (final dynamic row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }

      final String? id = _cleanNullableText(
        row[BookingBarberColumnNames.id]?.toString(),
      );

      if (id != null) {
        result[id] = row;
      }
    }

    return result;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _loadServicesByAppointmentId(
    Set<String> appointmentIds,
  ) async {
    if (appointmentIds.isEmpty) {
      return <String, List<Map<String, dynamic>>>{};
    }

    final List<dynamic> rows = await SupabaseConfig.client
        .from(BookingTableNames.appointmentServices)
        .select(
          '${AppointmentServiceColumnNames.appointmentId}, '
          '${AppointmentServiceColumnNames.serviceNameSnapshot}, '
          '${AppointmentServiceColumnNames.serviceTarget}, '
          '${AppointmentServiceColumnNames.createdAt}',
        )
        .inFilter(
          AppointmentServiceColumnNames.appointmentId,
          appointmentIds.toList(),
        )
        .order(AppointmentServiceColumnNames.createdAt);

    final Map<String, List<Map<String, dynamic>>> result =
        <String, List<Map<String, dynamic>>>{};

    for (final dynamic row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }

      final String? appointmentId = _cleanNullableText(
        row[AppointmentServiceColumnNames.appointmentId]?.toString(),
      );

      if (appointmentId == null) {
        continue;
      }

      result.putIfAbsent(appointmentId, () => <Map<String, dynamic>>[]);
      result[appointmentId]!.add(row);
    }

    return result;
  }

  MockAppointment _mapAppointmentRowFromCachedData({
    required Map<String, dynamic> row,
    required Map<String, Map<String, dynamic>> customersById,
    required Map<String, Map<String, dynamic>> barbersById,
    required Map<String, List<Map<String, dynamic>>> servicesByAppointmentId,
  }) {
    final String appointmentId = row[AppointmentColumnNames.id].toString();

    final String? customerId = _cleanNullableText(
      row[AppointmentColumnNames.customerId]?.toString(),
    );

    final String barberId = row[AppointmentColumnNames.barberId].toString();

    final String? manualCustomerName = _cleanNullableText(
      row[AppointmentColumnNames.manualCustomerName]?.toString(),
    );

    final Map<String, dynamic>? customerRow = customerId == null
        ? null
        : customersById[customerId];

    final Map<String, dynamic>? barberRow = barbersById[barberId];

    final List<Map<String, dynamic>> serviceRows =
        servicesByAppointmentId[appointmentId] ?? <Map<String, dynamic>>[];

    final DateTime startDateTime = BookingDateTimeHelper.combineDateAndTime(
      row[AppointmentColumnNames.appointmentDate],
      row[AppointmentColumnNames.startTime],
    );

    final DateTime endDateTime = BookingDateTimeHelper.combineDateAndTime(
      row[AppointmentColumnNames.appointmentDate],
      row[AppointmentColumnNames.endTime],
    );

    final String customerName =
        manualCustomerName ?? _buildCustomerName(customerRow);

    final String barberName = (barberRow?[BookingBarberColumnNames.name] ?? '')
        .toString();

    final double barberRating = _parseDouble(
      barberRow?[BookingBarberColumnNames.rating],
    );

    final String serviceName = serviceRows
        .map((serviceRow) {
          final String name =
              (serviceRow[AppointmentServiceColumnNames.serviceNameSnapshot] ??
                      '')
                  .toString()
                  .trim();

          if (name.isEmpty) {
            return '';
          }

          final ServiceTarget target = ServiceTargetX.fromDatabaseValue(
            serviceRow[AppointmentServiceColumnNames.serviceTarget]?.toString(),
          );

          return '$name — ${target.arabicLabel}';
        })
        .where((name) => name.trim().isNotEmpty)
        .join(' - ');

    return MockAppointment(
      id: appointmentId,
      customerId: customerId,
      barberId: barberId,
      customerName: customerName,
      customerAvatarUrl: _cleanNullableText(
        customerRow?[BookingProfileColumnNames.avatarUrl]?.toString(),
      ),
      customerPhoneNumber: _cleanNullableText(
        customerRow?[BookingProfileColumnNames.phoneNumber]?.toString(),
      ),
      barberName: barberName,
      barberRating: barberRating,
      serviceName: serviceName.isEmpty ? 'خدمة غير محددة' : serviceName,
      dateLabel: BookingDateTimeHelper.formatDateLabel(startDateTime),
      timeLabel: BookingDateTimeHelper.formatAppointmentTimeRange(
        startDateTime,
        endDateTime,
      ),
      status: BookingStatusMapper.databaseToArabic(
        (row[AppointmentColumnNames.status] ?? '').toString(),
      ),
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      createdAt: _parseCreatedAt(row[AppointmentColumnNames.createdAt]),
      cancelledBy: AppointmentCancelledBy.tryParse(
        row[AppointmentColumnNames.cancelledBy]?.toString(),
      ),
    );
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

  String _buildCustomerName(Map<String, dynamic>? row) {
    if (row == null) {
      return 'زبون';
    }

    final String firstName = (row[BookingProfileColumnNames.firstName] ?? '')
        .toString()
        .trim();

    final String lastName = (row[BookingProfileColumnNames.lastName] ?? '')
        .toString()
        .trim();

    final String fullName = '$firstName $lastName'.trim();

    return fullName.isEmpty ? 'زبون' : fullName;
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
