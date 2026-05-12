// loading + filtering + appointments state

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/bookings/bookings.dart';
import '../../services/auth_session.dart';
import '../../features/barber/services_management/services_management.dart';
import '../../services/supabase_config.dart';

class BarberAppointmentsController extends ChangeNotifier {
  BarberAppointmentsController({
    BookingRepository bookingRepository = const BookingRepository(),
  }) : _bookingRepository = bookingRepository;

  final BookingRepository _bookingRepository;
  bool _isDisposed = false;
  RealtimeChannel? _appointmentsChannel;
  bool _isRealtimeSubscribed = false;
  bool _isSilentReloadInFlight = false;

  bool isLoadingAppointments = true;
  bool isLoadingMoreAppointments = false;
  bool hasMoreAppointments = true;
  String? appointmentsErrorMessage;

  List<MockAppointment> appointments = [];

  String selectedTab = 'today';
  void _safeNotifyListeners() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> loadBarberAppointments() async {
    await loadBarberAppointmentsWithMode(silent: false);
  }

  Future<void> loadBarberAppointmentsWithMode({bool silent = false}) async {
    final String barberId = _currentBarberId;

    if (!silent) {
      isLoadingAppointments = true;
      isLoadingMoreAppointments = false;
      hasMoreAppointments = true;
      appointmentsErrorMessage = null;
      _safeNotifyListeners();
    } else if (_isSilentReloadInFlight) {
      return;
    }

    if (silent) {
      _isSilentReloadInFlight = true;
    }

    try {
      if (barberId.isEmpty) {
        throw Exception('Missing current barber id');
      }

      if (!silent) {
        isLoadingMoreAppointments = false;
      }

      final int fetchLimit = silent
          ? (appointments.length > AppointmentPaging.pageSize
                ? appointments.length
                : AppointmentPaging.pageSize)
          : AppointmentPaging.pageSize;

      final List<MockAppointment> loadedAppointments =
          await _bookingRepository.getBarberAppointments(
            barberId: barberId,
            limit: fetchLimit,
            offset: 0,
          );

      if (_isDisposed) return;

      appointments = _dedupeAndSortAppointmentsChronological(loadedAppointments);
      hasMoreAppointments =
          loadedAppointments.length == fetchLimit;
      if (!silent) {
        isLoadingAppointments = false;
      }
      _safeNotifyListeners();
      _ensureRealtimeSubscription(barberId);
    } catch (error, stackTrace) {
      if (_isDisposed) return;
      debugPrint('BarberAppointmentsController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!silent) {
        appointmentsErrorMessage = 'تعذر تحميل مواعيد الحلاق، حاول مرة أخرى';
        isLoadingAppointments = false;
        _safeNotifyListeners();
      }
    } finally {
      if (silent) {
        _isSilentReloadInFlight = false;
      }
    }
  }

  Future<void> loadMoreAppointments() async {
    if (!hasMoreAppointments ||
        isLoadingMoreAppointments ||
        isLoadingAppointments) {
      return;
    }

    final String barberId = _currentBarberId;

    if (barberId.isEmpty) {
      return;
    }

    isLoadingMoreAppointments = true;
    _safeNotifyListeners();

    try {
      final int offset = appointments.length;
      final List<MockAppointment> batch =
          await _bookingRepository.getBarberAppointments(
            barberId: barberId,
            limit: AppointmentPaging.pageSize,
            offset: offset,
          );

      if (_isDisposed) return;

      appointments = _dedupeAndSortAppointmentsChronological([
        ...appointments,
        ...batch,
      ]);
      hasMoreAppointments =
          batch.length == AppointmentPaging.pageSize;
    } catch (error, stackTrace) {
      debugPrint('BarberAppointmentsController load-more error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoadingMoreAppointments = false;
      _safeNotifyListeners();
    }
  }

  List<MockAppointment> _dedupeAndSortAppointmentsChronological(
    List<MockAppointment> items,
  ) {
    final Map<String, MockAppointment> byId = <String, MockAppointment>{};
    for (final MockAppointment a in items) {
      if (a.id.isEmpty) continue;
      byId[a.id] = a;
    }
    final List<MockAppointment> out = byId.values.toList()
      ..sort((MockAppointment a, MockAppointment b) {
        final int c = a.startDateTime.compareTo(b.startDateTime);
        if (c != 0) return c;
        return a.id.compareTo(b.id);
      });
    return out;
  }

  bool _isSameCalendarDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<MockAppointment> get todayAppointments {
    final DateTime now = DateTime.now();

    return appointments.where((appointment) {
      return _isSameCalendarDay(appointment.startDateTime, now);
    }).toList();
  }

  List<MockAppointment> get otherAppointments {
    final DateTime now = DateTime.now();

    return appointments.where((appointment) {
      return !_isSameCalendarDay(appointment.startDateTime, now);
    }).toList();
  }

  List<MockAppointment> get activeAppointments {
    return selectedTab == 'today' ? todayAppointments : otherAppointments;
  }

  String get activeListTitle {
    return selectedTab == 'today' ? 'مواعيد اليوم' : 'حجوزات أخرى';
  }

  String get activeEmptyText {
    return selectedTab == 'today'
        ? 'لا توجد مواعيد اليوم حاليًا'
        : 'لا توجد حجوزات أخرى حاليًا';
  }

  bool isFinalStatus(String status) {
    return AppointmentStatusUtils.isFinal(status);
  }

  void changeTab(String tab) {
    selectedTab = tab;
    _safeNotifyListeners();
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _bookingRepository.updateAppointmentStatus(
        appointmentId: id,
        status: status,
        actor: AppointmentStatusActor.barber,
      );
    } catch (error) {
      if (_isFinalizedUpdateError(error)) {
        await loadBarberAppointments();
        throw const BarberAppointmentsSyncConflictException();
      }
      rethrow;
    }

    appointments = appointments.map((MockAppointment item) {
      if (item.id != id) return item;
      return item.copyWith(
        status: status,
        cancelledBy: AppointmentStatusUtils.isCancelled(status)
            ? AppointmentCancelledBy.barber
            : item.cancelledBy,
      );
    }).toList();

    _safeNotifyListeners();
  }

  Future<void> addManualAppointment({
    required String customerName,
    required List<ServiceModel> services,
    required DateTime startDateTime,
  }) async {
    if (_currentBarberId.isEmpty) {
      throw Exception('Missing current barber id');
    }

    final createdAppointment = await _bookingRepository.createManualAppointment(
      barberId: _currentBarberId,
      customerName: customerName,
      services: services,
      startDateTime: startDateTime,
    );

    appointments = _dedupeAndSortAppointmentsChronological([
      createdAppointment,
      ...appointments,
    ]);
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    final channel = _appointmentsChannel;
    if (channel != null) {
      SupabaseConfig.client.removeChannel(channel);
    }
    super.dispose();
  }

  bool _isFinalizedUpdateError(Object error) {
    if (error is! StateError) {
      return false;
    }
    return error.message.toString().contains('already finalized');
  }

  void _ensureRealtimeSubscription(String barberId) {
    if (_isRealtimeSubscribed || barberId.trim().isEmpty) {
      return;
    }

    _appointmentsChannel = SupabaseConfig.client.channel(
      'barber-appointments-$barberId',
    )..onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: BookingTableNames.appointments,
      callback: (payload) async {
        final String? eventBarberId = _extractEntityIdFromRealtimePayload(
          payload: payload,
          key: AppointmentColumnNames.barberId,
        );
        if (eventBarberId != barberId) {
          return;
        }
        _applyRealtimeAppointmentEvent(payload);
        await loadBarberAppointmentsWithMode(silent: true);
      },
    );

    _appointmentsChannel!.subscribe();
    _isRealtimeSubscribed = true;
  }

  String? _extractEntityIdFromRealtimePayload({
    required PostgresChangePayload payload,
    required String key,
  }) {
    final dynamic fromNew = payload.newRecord[key];
    if (fromNew != null && fromNew.toString().trim().isNotEmpty) {
      return fromNew.toString().trim();
    }

    final dynamic fromOld = payload.oldRecord[key];
    if (fromOld != null && fromOld.toString().trim().isNotEmpty) {
      return fromOld.toString().trim();
    }

    return null;
  }

  void _applyRealtimeAppointmentEvent(PostgresChangePayload payload) {
    final Map<String, dynamic> newRecord = payload.newRecord;
    final Map<String, dynamic> oldRecord = payload.oldRecord;
    final bool hasNew = newRecord.isNotEmpty;
    final bool hasOld = oldRecord.isNotEmpty;

    if (hasNew && hasOld) {
      _applyRealtimeAppointmentPatch(newRecord);
      return;
    }

    if (!hasNew && hasOld) {
      final String? appointmentId =
          oldRecord[AppointmentColumnNames.id]?.toString().trim();
      if (appointmentId == null || appointmentId.isEmpty) {
        return;
      }
      final int beforeLength = appointments.length;
      appointments = appointments.where((item) => item.id != appointmentId).toList();
      if (appointments.length != beforeLength) {
        _safeNotifyListeners();
      }
    }
  }

  void _applyRealtimeAppointmentPatch(Map<String, dynamic> record) {
    final String? appointmentId =
        record[AppointmentColumnNames.id]?.toString().trim();
    final String? databaseStatus =
        record[AppointmentColumnNames.status]?.toString().trim();
    if (appointmentId == null ||
        appointmentId.isEmpty ||
        databaseStatus == null ||
        databaseStatus.isEmpty) {
      return;
    }

    final String arabicStatus = BookingStatusMapper.databaseToArabic(
      databaseStatus,
    );
    final AppointmentCancelledBy? cancelledBy = AppointmentCancelledBy.tryParse(
      record[AppointmentColumnNames.cancelledBy]?.toString(),
    );

    bool changed = false;
    appointments = appointments.map((item) {
      if (item.id != appointmentId) {
        return item;
      }
      changed = true;
      return item.copyWith(
        status: arabicStatus,
        cancelledBy: cancelledBy ?? item.cancelledBy,
      );
    }).toList();

    if (changed) {
      _safeNotifyListeners();
    }
  }
}

class BarberAppointmentsSyncConflictException implements Exception {
  const BarberAppointmentsSyncConflictException();
}
