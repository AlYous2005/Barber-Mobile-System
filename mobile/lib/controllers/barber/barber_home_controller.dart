// appointments + filters + timeline state + menu state

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/notifications/notifications.dart';
import '../../features/bookings/bookings.dart';
import '../../services/auth_session.dart';
import '../../features/barber/profile/barber_profile.dart';
import '../../services/supabase_config.dart';

class BarberHomeController extends ChangeNotifier {
  BarberHomeController({
    BookingRepository bookingRepository = const BookingRepository(),
    BarberAvatarRepository barberAvatarRepository =
        const BarberAvatarRepository(),
    NotificationRepository notificationRepository =
        const NotificationRepository(),
    BarberReviewSummaryRepository reviewSummaryRepository =
        const BarberReviewSummaryRepository(),
  }) : _bookingRepository = bookingRepository,
       _barberAvatarRepository = barberAvatarRepository,
       _notificationRepository = notificationRepository,
       _reviewSummaryRepository = reviewSummaryRepository;

  final BookingRepository _bookingRepository;
  final BarberAvatarRepository _barberAvatarRepository;
  final NotificationRepository _notificationRepository;
  final BarberReviewSummaryRepository _reviewSummaryRepository;
  RealtimeChannel? _appointmentsChannel;
  RealtimeChannel? _notificationsChannel;
  bool _isRealtimeSubscribed = false;
  bool _isNotificationsRealtimeSubscribed = false;
  bool _isSilentReloadInFlight = false;
  bool shouldAnimateNotificationBell = false;

  bool isLoadingAppointments = true;
  bool isLoadingMoreAppointments = false;
  bool hasMoreAppointments = true;
  String? appointmentsErrorMessage;
  List<MockAppointment> barberAppointments = [];

  BarberHomeAppointmentCounts _homeAppointmentCounts =
      BarberHomeAppointmentCounts.empty;
  MockAppointment? _timelineCurrentAppointment;
  MockAppointment? _timelineUpcomingAppointment;

  bool showCurrent = true;
  bool isMenuOpen = false;
  String barberDisplayName = 'الحلاق';
  double barberRating = 0;
  int barberRatingCount = 0;
  int barberSatisfactionRate = 0;
  Map<int, int> barberRatingBreakdown =
      BarberRatingSummary.empty.ratingBreakdown;
  String? barberAvatarUrl;
  String selectedAppointmentFilter = 'معلقة';

  int unreadNotifications = 0;

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
  }

  Future<void> loadUnreadNotificationsCount() async {
    final userId = _currentUserId;

    if (userId.isEmpty) {
      return;
    }

    try {
      final int oldUnread = unreadNotifications;
      unreadNotifications = await _notificationRepository.getUnreadCount(
        userId: userId,
      );
      _ensureNotificationsRealtimeSubscription(userId);
      if (unreadNotifications > oldUnread) {
        shouldAnimateNotificationBell = true;
      }

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController notifications count error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void consumeNotificationBellAnimation() {
    if (!shouldAnimateNotificationBell) {
      return;
    }
    shouldAnimateNotificationBell = false;
    notifyListeners();
  }

  Future<void> loadBarberProfileSummary() async {
    final userId = _currentUserId;
    final barberId = _currentBarberId;

    if (userId.isEmpty) {
      return;
    }

    try {
      final profileRow = await SupabaseConfig.client
          .from('profiles')
          .select('first_name, last_name, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      Map<String, dynamic>? barberRow;

      if (barberId.isNotEmpty) {
        barberRow = await SupabaseConfig.client
            .from('barbers')
            .select('name, rating')
            .eq('id', barberId)
            .maybeSingle();
      }

      final firstName = (profileRow?['first_name'] ?? '').toString().trim();
      final lastName = (profileRow?['last_name'] ?? '').toString().trim();
      final profileFullName = '$firstName $lastName'.trim();

      final barberName = (barberRow?['name'] ?? '').toString().trim();

      barberDisplayName = barberName.isNotEmpty
          ? barberName
          : profileFullName.isNotEmpty
          ? profileFullName
          : AuthSession.currentUser?.displayName.trim().isNotEmpty == true
          ? AuthSession.currentUser!.displayName
          : 'الحلاق';

      final ratingSummary = barberId.isEmpty
          ? BarberRatingSummary.empty
          : await _reviewSummaryRepository.getSummaryForBarber(
              barberId: barberId,
            );

      barberRating = ratingSummary.ratingCount == 0
          ? _parseRating(barberRow?['rating'])
          : ratingSummary.averageRating;

      barberRatingCount = ratingSummary.ratingCount;
      barberSatisfactionRate = ratingSummary.satisfactionRate;
      barberRatingBreakdown = ratingSummary.ratingBreakdown;

      barberAvatarUrl = _cleanNullableText(
        profileRow?['avatar_url']?.toString(),
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController profile summary load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> loadBarberAvatar() async {
    final userId = _currentUserId;

    if (userId.isEmpty) {
      return;
    }

    try {
      barberAvatarUrl = await _barberAvatarRepository.getBarberAvatarUrl(
        userId: userId,
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController avatar load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      await _bookingRepository.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
        actor: AppointmentStatusActor.barber,
      );
    } catch (error) {
      if (_isFinalizedUpdateError(error)) {
        await loadBarberAppointments();
        throw const BarberAppointmentSyncConflictException();
      }
      rethrow;
    }

    barberAppointments = barberAppointments.map((appointment) {
      if (appointment.id != appointmentId) {
        return appointment;
      }

      return appointment.copyWith(
        status: status,
        cancelledBy: AppointmentStatusUtils.isCancelled(status)
            ? AppointmentCancelledBy.barber
            : appointment.cancelledBy,
      );
    }).toList();

    await _loadBarberHomeSummaryAndTimeline();

    notifyListeners();
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
      notifyListeners();
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

      final int fetchCardLimit = silent
          ? (barberAppointments.length > AppointmentPaging.pageSize
                ? barberAppointments.length
                : AppointmentPaging.pageSize)
          : AppointmentPaging.pageSize;

      final DateTime now = DateTime.now();
      final List<Object?> bundle = await Future.wait<Object?>([
        _bookingRepository.getBarberAppointments(
          barberId: barberId,
          limit: fetchCardLimit,
          offset: 0,
          chronologicalAscendingPagination: true,
        ),
        _bookingRepository.getBarberHomeAppointmentCounts(barberId: barberId),
        _bookingRepository.getBarberCurrentTimelineAppointment(
          barberId: barberId,
          now: now,
        ),
        _bookingRepository.getBarberUpcomingTimelineAppointment(
          barberId: barberId,
          now: now,
        ),
      ]);

      final List<MockAppointment> loadedCards =
          bundle[0]! as List<MockAppointment>;

      barberAppointments =
          _dedupeAndSortAppointmentsChronological(loadedCards);
      hasMoreAppointments = loadedCards.length == fetchCardLimit;

      _homeAppointmentCounts =
          bundle[1]! as BarberHomeAppointmentCounts;
      _timelineCurrentAppointment = bundle[2] as MockAppointment?;
      _timelineUpcomingAppointment = bundle[3] as MockAppointment?;

      if (!silent) {
        isLoadingAppointments = false;
      }
      notifyListeners();

      _ensureRealtimeSubscription(barberId);
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!silent) {
        appointmentsErrorMessage = 'تعذر تحميل مواعيد الحلاق، حاول مرة أخرى';
        isLoadingAppointments = false;
        notifyListeners();
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
    notifyListeners();

    try {
      final int offset = barberAppointments.length;
      final List<MockAppointment> batch =
          await _bookingRepository.getBarberAppointments(
            barberId: barberId,
            limit: AppointmentPaging.pageSize,
            offset: offset,
            chronologicalAscendingPagination: true,
          );

      barberAppointments = _dedupeAndSortAppointmentsChronological([
        ...barberAppointments,
        ...batch,
      ]);
      hasMoreAppointments =
          batch.length == AppointmentPaging.pageSize;
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController appointments load-more error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoadingMoreAppointments = false;
      notifyListeners();
    }
  }

  List<MockAppointment> _dedupeAndSortAppointmentsChronological(
    List<MockAppointment> items,
  ) {
    final Map<String, MockAppointment> byId = <String, MockAppointment>{};
    for (final MockAppointment a in items) {
      if (a.id.isEmpty) {
        continue;
      }
      byId[a.id] = a;
    }
    final List<MockAppointment> out = byId.values.toList()
      ..sort((MockAppointment a, MockAppointment b) {
        final int c = a.startDateTime.compareTo(b.startDateTime);
        if (c != 0) {
          return c;
        }
        return a.id.compareTo(b.id);
      });
    return out;
  }

  Future<void> _loadBarberHomeSummaryAndTimeline() async {
    final String barberId = _currentBarberId;

    if (barberId.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();

    try {
      final List<Object?> bundle = await Future.wait<Object?>([
        _bookingRepository.getBarberHomeAppointmentCounts(barberId: barberId),
        _bookingRepository.getBarberCurrentTimelineAppointment(
          barberId: barberId,
          now: now,
        ),
        _bookingRepository.getBarberUpcomingTimelineAppointment(
          barberId: barberId,
          now: now,
        ),
      ]);

      _homeAppointmentCounts =
          bundle[0]! as BarberHomeAppointmentCounts;
      _timelineCurrentAppointment = bundle[1] as MockAppointment?;
      _timelineUpcomingAppointment = bundle[2] as MockAppointment?;
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController summary/timeline refresh error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  MockAppointment? get currentTimelineAppointment {
    return _timelineCurrentAppointment;
  }

  MockAppointment? get upcomingTimelineAppointment {
    return _timelineUpcomingAppointment;
  }

  int get pendingAppointmentsCount {
    return _homeAppointmentCounts.pending;
  }

  int get confirmedAppointmentsCount {
    return _homeAppointmentCounts.confirmed;
  }

  int get completedAppointmentsCount {
    return _homeAppointmentCounts.completed;
  }

  int get cancelledAppointmentsCount {
    return _homeAppointmentCounts.cancelled;
  }

  bool statusMatchesFilter(MockAppointment appointment) {
    final String status = appointment.status;

    switch (selectedAppointmentFilter) {
      case 'معلقة':
        return AppointmentStatusUtils.isPending(status);
      case 'مؤكدة':
        return AppointmentStatusUtils.isConfirmed(status);
      case 'مكتملة':
        return AppointmentStatusUtils.isCompleted(status);
      case 'ملغية':
        return AppointmentStatusUtils.isCancelled(status);
      case 'الكل':
        return true;
      default:
        return false;
    }
  }

  List<MockAppointment> get filteredAppointments {
    if (selectedAppointmentFilter == 'الكل') {
      return barberAppointments;
    }

    return barberAppointments.where(statusMatchesFilter).toList();
  }

  String get appointmentsSectionTitle {
    switch (selectedAppointmentFilter) {
      case 'معلقة':
        return 'المواعيد المعلقة';
      case 'مؤكدة':
        return 'المواعيد المؤكدة';
      case 'مكتملة':
        return 'المواعيد المكتملة';
      case 'ملغية':
        return 'المواعيد الملغية';
      default:
        return 'كل المواعيد';
    }
  }

  void toggleTimelineMode() {
    showCurrent = !showCurrent;
    notifyListeners();
  }

  void changeAppointmentFilter(String value) {
    selectedAppointmentFilter = value;
    notifyListeners();
  }

  void showAllAppointments() {
    selectedAppointmentFilter = 'الكل';
    notifyListeners();
  }

  void openMenu() {
    isMenuOpen = true;
    notifyListeners();
  }

  void closeMenu() {
    isMenuOpen = false;
    notifyListeners();
  }

  String? _cleanNullableText(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  bool _isFinalizedUpdateError(Object error) {
    if (error is! StateError) {
      return false;
    }
    return error.message.toString().contains('already finalized');
  }

  double _parseRating(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  void updateBarberDisplayName(String newName) {
    barberDisplayName = newName;
    notifyListeners();
  }

  void _ensureRealtimeSubscription(String barberId) {
    if (_isRealtimeSubscribed || barberId.trim().isEmpty) {
      return;
    }

    _appointmentsChannel = SupabaseConfig.client.channel(
      'barber-home-appointments-$barberId',
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
        if (payload.eventType == PostgresChangeEvent.insert) {
          await _mergeBarberHomeInsertIfMissing(payload.newRecord);
        }
      },
    );

    _appointmentsChannel!.subscribe();
    _isRealtimeSubscribed = true;
  }

  void _ensureNotificationsRealtimeSubscription(String userId) {
    if (_isNotificationsRealtimeSubscribed || userId.trim().isEmpty) {
      return;
    }

    _notificationsChannel = SupabaseConfig.client.channel(
      'barber-notifications-$userId',
    )..onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: NotificationTableNames.notifications,
      callback: (payload) async {
        final String? eventUserId = _extractEntityIdFromRealtimePayload(
          payload: payload,
          key: NotificationColumnNames.userId,
        );
        if (eventUserId != userId) {
          return;
        }
        final int oldUnread = unreadNotifications;
        final int newUnread = await _notificationRepository.getUnreadCount(
          userId: userId,
        );
        unreadNotifications = newUnread;
        if (newUnread > oldUnread) {
          shouldAnimateNotificationBell = true;
        }
        notifyListeners();
      },
    );

    _notificationsChannel!.subscribe();
    _isNotificationsRealtimeSubscribed = true;
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
      final int beforeLength = barberAppointments.length;
      barberAppointments = barberAppointments
          .where((item) => item.id != appointmentId)
          .toList();
      if (barberAppointments.length != beforeLength) {
        notifyListeners();
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
    barberAppointments = barberAppointments.map((item) {
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
      notifyListeners();
    }
  }

  Future<void> _mergeBarberHomeInsertIfMissing(
    Map<String, dynamic> newRecord,
  ) async {
    if (newRecord.isEmpty) {
      return;
    }

    final String barberId = _currentBarberId;
    final String? appointmentId =
        newRecord[AppointmentColumnNames.id]?.toString().trim();

    if (barberId.isEmpty ||
        appointmentId == null ||
        appointmentId.isEmpty) {
      return;
    }

    if (barberAppointments.any((MockAppointment e) => e.id == appointmentId)) {
      return;
    }

    try {
      final MockAppointment? inserted =
          await _bookingRepository.getBarberAppointmentByIdForBarber(
            barberId: barberId,
            appointmentId: appointmentId,
          );

      if (inserted == null) {
        return;
      }

      barberAppointments = _dedupeAndSortAppointmentsChronological([
        ...barberAppointments,
        inserted,
      ]);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController insert merge error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    final appointmentsChannel = _appointmentsChannel;
    if (appointmentsChannel != null) {
      SupabaseConfig.client.removeChannel(appointmentsChannel);
    }
    final notificationsChannel = _notificationsChannel;
    if (notificationsChannel != null) {
      SupabaseConfig.client.removeChannel(notificationsChannel);
    }
    super.dispose();
  }
}

class BarberAppointmentSyncConflictException implements Exception {
  const BarberAppointmentSyncConflictException();
}
