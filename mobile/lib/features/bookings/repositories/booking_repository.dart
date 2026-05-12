import '../../../services/supabase_config.dart';
import '../../../../features/bookings/bookings.dart';
import '../../barber/services_management/services_management.dart';

class BookingRepository implements BookingRepositoryContract {
  const BookingRepository({
    this.statusNotificationService = const BookingStatusNotificationService(),
    this.appointmentMapper = const BookingAppointmentMapper(),
  });

  final BookingStatusNotificationService statusNotificationService;
  final BookingAppointmentMapper appointmentMapper;

  @override
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    AppointmentStatusActor actor = AppointmentStatusActor.system,
  }) async {
    final String databaseStatus = BookingStatusMapper.arabicToDatabase(status);

    final appointmentRow = await _getAppointmentNotificationRow(appointmentId);
    final String previousStatus =
        appointmentRow?['status']?.toString().trim() ?? '';

    if (previousStatus == databaseStatus) {
      return;
    }

    if (_isFinalDatabaseStatus(previousStatus)) {
      throw StateError(
        'Cannot update appointment because it is already finalized',
      );
    }

    final Map<String, dynamic> patch = <String, dynamic>{
      AppointmentColumnNames.status: databaseStatus,
    };
    if (databaseStatus == AppointmentStatuses.cancelled) {
      patch[AppointmentColumnNames.cancelledBy] = _cancelledByStorage(actor);
    }

    await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .update(patch)
        .eq(AppointmentColumnNames.id, appointmentId);

    await statusNotificationService.notifyAfterStatusChange(
      appointmentId: appointmentId,
      databaseStatus: databaseStatus,
      appointmentRow: appointmentRow,
      actor: actor,
    );
  }

  @override
  Future<void> createAppointmentReview({
    required String barberId,
    required String customerId,
    required String appointmentId,
    required int rating,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'Rating must be from 1 to 5');
    }

    await SupabaseConfig.client.from(BookingTableNames.barberReviews).insert({
      BarberReviewColumnNames.barberId: barberId,
      BarberReviewColumnNames.customerId: customerId,
      BarberReviewColumnNames.appointmentId: appointmentId,
      BarberReviewColumnNames.rating: rating,
    });
  }

  Future<Map<String, dynamic>?> _getAppointmentNotificationRow(
    String appointmentId,
  ) {
    return SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select(
          '${AppointmentColumnNames.customerId}, '
          '${AppointmentColumnNames.barberId}, '
          '${AppointmentColumnNames.status}',
        )
        .eq(AppointmentColumnNames.id, appointmentId)
        .maybeSingle();
  }

  String _cancelledByStorage(AppointmentStatusActor actor) {
    switch (actor) {
      case AppointmentStatusActor.barber:
        return 'barber';
      case AppointmentStatusActor.customer:
        return 'customer';
      case AppointmentStatusActor.system:
        return 'system';
    }
  }

  bool _isActiveDatabaseStatus(String raw) {
    final String s = raw.trim();
    return s != AppointmentStatuses.completed &&
        s != AppointmentStatuses.cancelled &&
        s != AppointmentStatuses.noShow;
  }

  bool _isFinalDatabaseStatus(String raw) {
    final String s = raw.trim();
    return s == AppointmentStatuses.completed ||
        s == AppointmentStatuses.cancelled ||
        s == AppointmentStatuses.noShow;
  }

  Future<List<String>> _activeAppointmentIdsForBarberService({
    required String barberId,
    required String serviceId,
  }) async {
    final List<dynamic> links = await SupabaseConfig.client
        .from(BookingTableNames.appointmentServices)
        .select(AppointmentServiceColumnNames.appointmentId)
        .eq(AppointmentServiceColumnNames.serviceId, serviceId);

    final Set<String> ids = links
        .map((dynamic e) {
          if (e is! Map) return null;
          return e[AppointmentServiceColumnNames.appointmentId]?.toString();
        })
        .whereType<String>()
        .where((String id) => id.isNotEmpty)
        .toSet();

    if (ids.isEmpty) {
      return <String>[];
    }

    final List<dynamic> rows = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select(
          '${AppointmentColumnNames.id}, ${AppointmentColumnNames.status}',
        )
        .eq(AppointmentColumnNames.barberId, barberId)
        .inFilter(AppointmentColumnNames.id, ids.toList());

    final List<String> active = <String>[];
    for (final dynamic row in rows) {
      if (row is! Map) continue;
      final String? id = row[AppointmentColumnNames.id]?.toString();
      final String st = (row[AppointmentColumnNames.status] ?? '').toString();
      if (id != null && id.isNotEmpty && _isActiveDatabaseStatus(st)) {
        active.add(id);
      }
    }
    return active;
  }

  @override
  Future<int> countActiveAppointmentsForService({
    required String barberId,
    required String serviceId,
  }) async {
    final List<String> active = await _activeAppointmentIdsForBarberService(
      barberId: barberId,
      serviceId: serviceId,
    );
    return active.length;
  }

  @override
  Future<void> cancelActiveAppointmentsForService({
    required String barberId,
    required String serviceId,
  }) async {
    final List<String> active = await _activeAppointmentIdsForBarberService(
      barberId: barberId,
      serviceId: serviceId,
    );
    for (final String id in active) {
      await updateAppointmentStatus(
        appointmentId: id,
        status: 'ملغي',
        actor: AppointmentStatusActor.barber,
      );
    }
  }

  @override
  Future<List<MockAppointment>> getCustomerAppointments({
    required String customerId,
    int? limit,
    int offset = 0,
  }) async {
    if (limit != null && limit <= 0) {
      return [];
    }

    dynamic query = SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select()
        .eq(AppointmentColumnNames.customerId, customerId);

    if (limit != null) {
      query = query
          .order(AppointmentColumnNames.appointmentDate, ascending: false)
          .order(AppointmentColumnNames.startTime, ascending: false)
          .order(AppointmentColumnNames.createdAt, ascending: false)
          .range(offset, offset + limit - 1);
    } else {
      query = query
          .order(AppointmentColumnNames.appointmentDate)
          .order(AppointmentColumnNames.startTime);
    }

    final List<dynamic> rows = await query as List<dynamic>;

    final List<String> appointmentIds = rows
        .map<String?>((row) => row[AppointmentColumnNames.id]?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toList();
    final Map<String, int> ratingsByAppointmentId = {};

    if (appointmentIds.isNotEmpty) {
      final reviewRows = await SupabaseConfig.client
          .from(BookingTableNames.barberReviews)
          .select(
            '${BarberReviewColumnNames.appointmentId}, '
            '${BarberReviewColumnNames.rating}',
          )
          .eq(BarberReviewColumnNames.customerId, customerId)
          .inFilter(BarberReviewColumnNames.appointmentId, appointmentIds);

      for (final reviewRow in reviewRows) {
        final appointmentId = reviewRow[BarberReviewColumnNames.appointmentId]
            ?.toString();

        final ratingValue = int.tryParse(
          reviewRow[BarberReviewColumnNames.rating]?.toString() ?? '',
        );

        if (appointmentId != null &&
            appointmentId.trim().isNotEmpty &&
            ratingValue != null) {
          ratingsByAppointmentId[appointmentId] = ratingValue;
        }
      }
    }

    final List<MockAppointment> appointments = await appointmentMapper
        .mapAppointmentRows(rows);

    return appointments.map((appointment) {
      return appointment.copyWith(
        customerRating: ratingsByAppointmentId[appointment.id],
      );
    }).toList();
  }

  @override
  Future<List<MockAppointment>> getBarberAppointments({
    required String barberId,
    int? limit,
    int offset = 0,
    bool chronologicalAscendingPagination = false,
  }) async {
    if (limit != null && limit <= 0) {
      return [];
    }

    dynamic query = SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select()
        .eq(AppointmentColumnNames.barberId, barberId);

    if (limit != null) {
      if (chronologicalAscendingPagination) {
        query = query
            .order(AppointmentColumnNames.appointmentDate)
            .order(AppointmentColumnNames.startTime)
            .order(AppointmentColumnNames.createdAt)
            .range(offset, offset + limit - 1);
      } else {
        query = query
            .order(AppointmentColumnNames.appointmentDate, ascending: false)
            .order(AppointmentColumnNames.startTime, ascending: false)
            .order(AppointmentColumnNames.createdAt, ascending: false)
            .range(offset, offset + limit - 1);
      }
    } else {
      query = query
          .order(AppointmentColumnNames.appointmentDate)
          .order(AppointmentColumnNames.startTime);
    }

    final List<dynamic> rows = await query as List<dynamic>;

    return appointmentMapper.mapAppointmentRows(rows);
  }

  @override
  Future<MockAppointment?> getBarberAppointmentByIdForBarber({
    required String barberId,
    required String appointmentId,
  }) async {
    final Map<String, dynamic>? row = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select()
        .eq(AppointmentColumnNames.id, appointmentId)
        .eq(AppointmentColumnNames.barberId, barberId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return appointmentMapper.mapAppointmentRow(row);
  }

  Future<int> _countBarberAppointmentsWithStatus({
    required String barberId,
    required String databaseStatus,
  }) async {
    final dynamic rows = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select(AppointmentColumnNames.id)
        .eq(AppointmentColumnNames.barberId, barberId)
        .eq(AppointmentColumnNames.status, databaseStatus);

    if (rows is! List) {
      return 0;
    }

    return rows.length;
  }

  @override
  Future<BarberHomeAppointmentCounts> getBarberHomeAppointmentCounts({
    required String barberId,
  }) async {
    final List<int> counts = await Future.wait<int>([
      _countBarberAppointmentsWithStatus(
        barberId: barberId,
        databaseStatus: AppointmentStatuses.pending,
      ),
      _countBarberAppointmentsWithStatus(
        barberId: barberId,
        databaseStatus: AppointmentStatuses.confirmed,
      ),
      _countBarberAppointmentsWithStatus(
        barberId: barberId,
        databaseStatus: AppointmentStatuses.completed,
      ),
      _countBarberAppointmentsWithStatus(
        barberId: barberId,
        databaseStatus: AppointmentStatuses.cancelled,
      ),
      _countBarberAppointmentsWithStatus(
        barberId: barberId,
        databaseStatus: AppointmentStatuses.noShow,
      ),
    ]);

    return BarberHomeAppointmentCounts(
      pending: counts[0],
      confirmed: counts[1],
      completed: counts[2],
      cancelled: counts[3],
      noShow: counts[4],
    );
  }

  @override
  Future<MockAppointment?> getBarberCurrentTimelineAppointment({
    required String barberId,
    required DateTime now,
  }) async {
    final String from = BookingDateTimeHelper.formatDateForDatabase(
      now.subtract(const Duration(days: 2)),
    );
    final String to = BookingDateTimeHelper.formatDateForDatabase(
      now.add(const Duration(days: 2)),
    );

    final dynamic raw = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select()
        .eq(AppointmentColumnNames.barberId, barberId)
        .eq(AppointmentColumnNames.status, AppointmentStatuses.confirmed)
        .gte(AppointmentColumnNames.appointmentDate, from)
        .lte(AppointmentColumnNames.appointmentDate, to)
        .order(AppointmentColumnNames.appointmentDate)
        .order(AppointmentColumnNames.startTime);

    if (raw is! List) {
      return null;
    }

    for (final dynamic row in raw) {
      if (row is! Map) {
        continue;
      }

      final MockAppointment appointment = await appointmentMapper
          .mapAppointmentRow(Map<String, dynamic>.from(row));

      final bool hasStarted = !appointment.startDateTime.isAfter(now);
      final bool hasNotEnded = appointment.endDateTime.isAfter(now);

      if (hasStarted && hasNotEnded) {
        return appointment;
      }
    }

    return null;
  }

  @override
  Future<MockAppointment?> getBarberUpcomingTimelineAppointment({
    required String barberId,
    required DateTime now,
  }) async {
    final String fromDate = BookingDateTimeHelper.formatDateForDatabase(
      now.subtract(const Duration(days: 1)),
    );

    final dynamic raw = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select()
        .eq(AppointmentColumnNames.barberId, barberId)
        .eq(AppointmentColumnNames.status, AppointmentStatuses.confirmed)
        .gte(AppointmentColumnNames.appointmentDate, fromDate)
        .order(AppointmentColumnNames.appointmentDate)
        .order(AppointmentColumnNames.startTime)
        .limit(200);

    if (raw is! List) {
      return null;
    }

    for (final dynamic row in raw) {
      if (row is! Map) {
        continue;
      }

      final MockAppointment appointment = await appointmentMapper
          .mapAppointmentRow(Map<String, dynamic>.from(row));

      if (appointment.startDateTime.isAfter(now)) {
        return appointment;
      }
    }

    return null;
  }

  @override
  Future<List<MockAppointment>> getBarberAppointmentsForDate({
    required String barberId,
    required DateTime date,
  }) async {
    final String dateForDatabase = BookingDateTimeHelper.formatDateForDatabase(
      date,
    );

    final rows = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .select()
        .eq(AppointmentColumnNames.barberId, barberId)
        .eq(AppointmentColumnNames.appointmentDate, dateForDatabase)
        .order(AppointmentColumnNames.startTime);

    final List<MockAppointment> appointments = [];

    for (final row in rows) {
      appointments.add(await appointmentMapper.mapAppointmentRow(row));
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
    final payload = BookingCreatePayloadBuilder.buildAppointmentData(
      booking: booking,
      selectedServices: selectedServices,
      customerId: customerId,
    );

    final appointmentRow = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .insert(payload.appointmentData)
        .select(AppointmentColumnNames.id)
        .single();

    final String appointmentId = appointmentRow[AppointmentColumnNames.id]
        .toString();

    final serviceRows = BookingCreatePayloadBuilder.buildServiceRows(
      appointmentId: appointmentId,
      selectedServices: selectedServices,
    );

    await SupabaseConfig.client
        .from(BookingTableNames.appointmentServices)
        .insert(serviceRows);

    await statusNotificationService.notifyBarberAboutNewBooking(
      barberId: booking.barber.id,
      customerName: customerName,
      appointmentId: appointmentId,
    );

    return booking;
  }

  @override
  Future<MockAppointment> createManualAppointment({
    required String barberId,
    required String customerName,
    required List<ServiceModel> services,
    required DateTime startDateTime,
  }) async {
    if (services.isEmpty) {
      throw Exception('At least one service is required');
    }

    final int totalDuration = services.fold(
      0,
      (sum, service) => sum + service.durationMinutes,
    );

    final int totalPrice = services.fold(
      0,
      (sum, service) => sum + service.price,
    );

    final DateTime endDateTime = startDateTime.add(
      Duration(minutes: totalDuration),
    );

    final appointmentRow = await SupabaseConfig.client
        .from(BookingTableNames.appointments)
        .insert({
          AppointmentColumnNames.customerId: null,
          AppointmentColumnNames.manualCustomerName: customerName.trim(),
          AppointmentColumnNames.barberId: barberId,
          AppointmentColumnNames.appointmentDate:
              BookingDateTimeHelper.formatDateForDatabase(startDateTime),
          AppointmentColumnNames.startTime:
              BookingDateTimeHelper.formatTimeForDatabase(startDateTime),
          AppointmentColumnNames.endTime:
              BookingDateTimeHelper.formatTimeForDatabase(endDateTime),
          AppointmentColumnNames.status: AppointmentStatuses.confirmed,
          AppointmentColumnNames.totalPrice: totalPrice,
          AppointmentColumnNames.totalDurationMinutes: totalDuration,
          AppointmentColumnNames.checkedIn: false,
          AppointmentColumnNames.reminderSent: false,
          AppointmentColumnNames.noShowMarked: false,
        })
        .select()
        .single();

    final String appointmentId = appointmentRow[AppointmentColumnNames.id]
        .toString();

    final serviceRows = services.map((service) {
      return {
        AppointmentServiceColumnNames.appointmentId: appointmentId,
        AppointmentServiceColumnNames.serviceId: service.id,
        AppointmentServiceColumnNames.serviceNameSnapshot: service.name,
        AppointmentServiceColumnNames.priceSnapshot: service.price,
        AppointmentServiceColumnNames.durationMinutesSnapshot:
            service.durationMinutes,
        AppointmentServiceColumnNames.serviceTarget:
            service.target.databaseValue,
      };
    }).toList();

    await SupabaseConfig.client
        .from(BookingTableNames.appointmentServices)
        .insert(serviceRows);

    return appointmentMapper.mapAppointmentRow(appointmentRow);
  }
}
