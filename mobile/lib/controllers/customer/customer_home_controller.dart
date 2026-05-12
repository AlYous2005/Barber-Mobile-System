// state + appointments + profile + notifications

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/notifications/notifications.dart';
import '../../features/barber/profile/barber_profile.dart';
import '../../features/customer/profile/customer_profile.dart';

import '../../features/bookings/bookings.dart';
import '../../services/auth_session.dart';
import '../../services/supabase_config.dart';

class CustomerHomeController extends ChangeNotifier {
  CustomerHomeController({
    required String initialUserName,
    BookingRepository bookingRepository = const BookingRepository(),
    BarberRepository barberRepository = const BarberRepository(),
    CustomerProfileRepository customerProfileRepository =
        const CustomerProfileRepository(),
    NotificationRepository notificationRepository =
        const NotificationRepository(),
  }) : _bookingRepository = bookingRepository,
       _barberRepository = barberRepository,
       _customerProfileRepository = customerProfileRepository,
       _notificationRepository = notificationRepository {
    _initializeProfile(initialUserName);
  }

  final BookingRepository _bookingRepository;
  final BarberRepository _barberRepository;
  final CustomerProfileRepository _customerProfileRepository;
  final NotificationRepository _notificationRepository;
  RealtimeChannel? _appointmentsChannel;
  RealtimeChannel? _notificationsChannel;
  bool _isRealtimeSubscribed = false;
  bool _isNotificationsRealtimeSubscribed = false;
  bool _isSilentReloadInFlight = false;
  bool _isSilentNotificationsReloadInFlight = false;

  bool isLoadingAppointments = true;
  String? appointmentsErrorMessage;

  String displayName = '';
  String countryCode = '+970';
  String phoneNumber = '599999999';
  String? avatarUrl;

  bool isNotificationsDropdownOpen = false;
  String selectedAppointmentsTab = 'upcoming';

  List<MockAppointment> appointments = [];
  List<AppNotification> customerNotifications = [];
  bool shouldAnimateNotificationBell = false;
  bool isLoadingMoreCustomerNotifications = false;
  bool hasMoreCustomerNotifications = true;

  bool isLoadingMoreAppointments = false;
  bool hasMoreAppointments = true;

  int get unreadNotifications {
    return customerNotifications.where((item) => !item.isRead).length;
  }

  String get greetingFirstName {
    final String trimmed = displayName.trim();

    if (trimmed.isEmpty) {
      return 'بك';
    }

    final List<String> parts = trimmed.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : trimmed;
  }

  List<MockAppointment> get upcomingAppointments {
    return appointments.where(isUpcomingAppointment).toList();
  }

  List<MockAppointment> get previousAppointments {
    return appointments.where(isPreviousAppointment).toList();
  }

  Future<BarberModel?> resolveBarberForRebook(
    MockAppointment appointment,
  ) async {
    return _barberRepository.findBarberByName(appointment.barberName);
  }

  void _initializeProfile(String initialUserName) {
    final sessionUser = AuthSession.currentUser;

    final sessionDisplay = (sessionUser?.displayName ?? '').trim();
    if (sessionDisplay.isNotEmpty) {
      displayName = sessionDisplay;
    } else {
      final normalizedName = initialUserName.trim();
      if (normalizedName.isNotEmpty) {
        displayName = normalizedName;
      }
    }

    final sessionPhone = sessionUser?.phoneNumber?.trim();
    if (sessionPhone != null &&
        sessionPhone.isNotEmpty &&
        sessionPhone != phoneNumber) {
      phoneNumber = sessionPhone;
    }
    avatarUrl = sessionUser?.avatarUrl;
  }

  Future<void> loadCustomerProfile() async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      final row = await _customerProfileRepository.getCustomerProfile(
        userId: currentUser.username,
      );

      if (row == null) {
        return;
      }

      final firstName = (row['first_name'] ?? '').toString().trim();
      final lastName = (row['last_name'] ?? '').toString().trim();
      final fullName = '$firstName $lastName'.trim();

      if (fullName.isNotEmpty) {
        displayName = fullName;
      }

      final storedPhone = (row['phone_number'] ?? '').toString().trim();
      if (storedPhone.isNotEmpty) {
        phoneNumber = storedPhone;
      }

      final storedAvatarUrl = (row['avatar_url'] ?? '').toString().trim();
      avatarUrl = storedAvatarUrl.isNotEmpty ? storedAvatarUrl : null;

      AuthSession.updateCurrentUser(
        currentUser.copyWith(
          displayName: displayName,
          firstName: firstName.isNotEmpty ? firstName : currentUser.firstName,
          lastName: lastName.isNotEmpty ? lastName : currentUser.lastName,
          phoneNumber: phoneNumber,
          avatarUrl: avatarUrl,
        ),
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('CustomerHomeController profile load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> loadCustomerAppointments() async {
    await loadCustomerAppointmentsWithMode(silent: false);
  }

  Future<void> loadCustomerAppointmentsWithMode({bool silent = false}) async {
    final currentUser = AuthSession.currentUser;
    final String customerId = currentUser?.username ?? 'guest_customer';

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
      if (!silent) {
        isLoadingMoreAppointments = false;
      }

      final int fetchLimit = silent
          ? (appointments.length > AppointmentPaging.pageSize
                ? appointments.length
                : AppointmentPaging.pageSize)
          : AppointmentPaging.pageSize;

      final List<MockAppointment> loadedAppointments =
          await _bookingRepository.getCustomerAppointments(
            customerId: customerId,
            limit: fetchLimit,
            offset: 0,
          );

      appointments = _dedupeAndSortAppointmentsChronological(loadedAppointments);
      hasMoreAppointments =
          loadedAppointments.length == fetchLimit;

      if (!silent) {
        isLoadingAppointments = false;
      }
      notifyListeners();
      _ensureRealtimeSubscription(customerId);
    } catch (_) {
      if (!silent) {
        appointmentsErrorMessage = 'تعذر تحميل المواعيد، حاول مرة أخرى';
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

    final currentUser = AuthSession.currentUser;
    final String customerId = currentUser?.username ?? 'guest_customer';

    isLoadingMoreAppointments = true;
    notifyListeners();

    try {
      final int offset = appointments.length;
      final List<MockAppointment> batch =
          await _bookingRepository.getCustomerAppointments(
            customerId: customerId,
            limit: AppointmentPaging.pageSize,
            offset: offset,
          );

      appointments = _dedupeAndSortAppointmentsChronological([
        ...appointments,
        ...batch,
      ]);
      hasMoreAppointments =
          batch.length == AppointmentPaging.pageSize;
    } catch (error, stackTrace) {
      debugPrint('CustomerHomeController appointments load-more error: $error');
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

  void updateProfile(CustomerProfileResult result) {
    displayName = result.displayName;
    countryCode = result.countryCode;
    phoneNumber = result.phoneNumber;
    avatarUrl = result.avatarUrl;

    _syncAuthSessionFromProfile(result);

    notifyListeners();
  }

  void _syncAuthSessionFromProfile(CustomerProfileResult result) {
    final currentUser = AuthSession.currentUser;
    if (currentUser == null) return;

    final trimmedDisplay = result.displayName.trim();
    final nameParts = trimmedDisplay
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    AuthSession.updateCurrentUser(
      currentUser.copyWith(
        displayName: result.displayName,
        firstName: nameParts.isNotEmpty
            ? nameParts.first
            : currentUser.firstName,
        lastName: nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : currentUser.lastName,
        phoneNumber: result.phoneNumber,
        avatarUrl: result.avatarUrl,
      ),
    );
  }

  Future<void> loadCustomerNotifications() async {
    await loadCustomerNotificationsWithMode(silent: false);
  }

  Future<void> loadCustomerNotificationsWithMode({bool silent = false}) async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    if (silent && _isSilentNotificationsReloadInFlight) {
      return;
    }

    if (silent) {
      _isSilentNotificationsReloadInFlight = true;
    }

    try {
      if (!silent) {
        isLoadingMoreCustomerNotifications = false;
      }

      final int oldUnread = unreadNotifications;
      final int silentCap = customerNotifications.length >
              NotificationPaging.pageSize
          ? customerNotifications.length
          : NotificationPaging.pageSize;
      final int fetchLimit =
          silent ? silentCap : NotificationPaging.pageSize;

      customerNotifications = await _notificationRepository.getNotifications(
        userId: currentUser.username,
        limit: fetchLimit,
        offset: 0,
      );

      hasMoreCustomerNotifications =
          customerNotifications.length == fetchLimit;

      _ensureNotificationsRealtimeSubscription(currentUser.username);
      if (unreadNotifications > oldUnread) {
        shouldAnimateNotificationBell = true;
      }

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('CustomerHomeController notifications load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (silent) {
        _isSilentNotificationsReloadInFlight = false;
      }
    }
  }

  Future<void> loadMoreCustomerNotifications() async {
    if (!hasMoreCustomerNotifications || isLoadingMoreCustomerNotifications) {
      return;
    }

    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    isLoadingMoreCustomerNotifications = true;
    notifyListeners();

    try {
      final int offset = customerNotifications.length;
      final batch = await _notificationRepository.getNotifications(
        userId: currentUser.username,
        limit: NotificationPaging.pageSize,
        offset: offset,
      );

      final Set<String> seen =
          customerNotifications.map((AppNotification e) => e.id).toSet();
      final List<AppNotification> merged = [...customerNotifications];
      for (final AppNotification row in batch) {
        if (seen.contains(row.id)) continue;
        seen.add(row.id);
        merged.add(row);
      }
      customerNotifications = merged;
      hasMoreCustomerNotifications =
          batch.length == NotificationPaging.pageSize;
    } catch (error, stackTrace) {
      debugPrint('CustomerHomeController notifications load-more error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoadingMoreCustomerNotifications = false;
      notifyListeners();
    }
  }

  void _prependCustomerNotificationFromPayload(Map<String, dynamic> raw) {
    if (raw.isEmpty) {
      return;
    }

    final AppNotification appended = AppNotification.fromMap(
      Map<String, dynamic>.from(raw),
    );

    if (appended.id.isEmpty) {
      return;
    }

    if (customerNotifications.any((AppNotification e) => e.id == appended.id)) {
      return;
    }

    customerNotifications = <AppNotification>[appended, ...customerNotifications];

    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null || unreadNotifications == 0) {
      return;
    }

    await _notificationRepository.markAllAsRead(userId: currentUser.username);

    customerNotifications = customerNotifications
        .map((item) => item.copyWith(isRead: true))
        .toList();
    shouldAnimateNotificationBell = false;

    notifyListeners();
  }

  void toggleNotificationsDropdown() {
    isNotificationsDropdownOpen = !isNotificationsDropdownOpen;
    if (isNotificationsDropdownOpen) {
      shouldAnimateNotificationBell = false;
    }
    notifyListeners();
  }

  void closeNotificationsDropdown() {
    if (!isNotificationsDropdownOpen) return;

    isNotificationsDropdownOpen = false;
    notifyListeners();
  }

  void changeAppointmentsTab(String tab) {
    selectedAppointmentsTab = tab;
    notifyListeners();
  }

  Future<void> cancelAppointment(MockAppointment appointment) async {
    if (hasAppointmentStarted(appointment)) {
      throw const CustomerAppointmentAlreadyStartedException();
    }

    try {
      await _bookingRepository.updateAppointmentStatus(
        appointmentId: appointment.id,
        status: 'ملغي',
        actor: AppointmentStatusActor.customer,
      );
    } catch (error) {
      if (_isFinalizedUpdateError(error)) {
        await loadCustomerAppointments();
        throw const CustomerAppointmentSyncConflictException();
      }
      rethrow;
    }

    appointments = appointments.map((item) {
      if (item.id == appointment.id) {
        return item.copyWith(
          status: 'ملغي',
          cancelledBy: AppointmentCancelledBy.customer,
        );
      }

      return item;
    }).toList();

    notifyListeners();
  }

  Future<void> submitAppointmentRating({
    required MockAppointment appointment,
    required int rating,
  }) async {
    final currentUser = AuthSession.currentUser;
    final customerId = appointment.customerId ?? currentUser?.username ?? '';
    final barberId = appointment.barberId ?? '';

    if (customerId.trim().isEmpty || barberId.trim().isEmpty) {
      throw StateError('Missing customer or barber id for appointment rating');
    }

    await _bookingRepository.createAppointmentReview(
      barberId: barberId,
      customerId: customerId,
      appointmentId: appointment.id,
      rating: rating,
    );

    appointments = appointments.map((item) {
      if (item.id == appointment.id) {
        return item.copyWith(customerRating: rating);
      }

      return item;
    }).toList();

    notifyListeners();
  }

  bool _isFinalizedUpdateError(Object error) {
    if (error is! StateError) {
      return false;
    }
    return error.message.toString().contains('already finalized');
  }

  void consumeNotificationBellAnimation() {
    if (!shouldAnimateNotificationBell) {
      return;
    }
    shouldAnimateNotificationBell = false;
    notifyListeners();
  }

  void _ensureRealtimeSubscription(String customerId) {
    if (_isRealtimeSubscribed || customerId.trim().isEmpty) {
      return;
    }

    _appointmentsChannel = SupabaseConfig.client.channel(
      'customer-appointments-$customerId',
    )..onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: BookingTableNames.appointments,
      callback: (payload) async {
        final String? eventCustomerId = _extractEntityIdFromRealtimePayload(
          payload: payload,
          key: AppointmentColumnNames.customerId,
        );
        if (eventCustomerId != customerId) {
          return;
        }
        _applyRealtimeAppointmentEvent(payload);
        await loadCustomerAppointmentsWithMode(silent: true);
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
      'customer-notifications-$userId',
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
        if (payload.eventType == PostgresChangeEvent.insert) {
          _prependCustomerNotificationFromPayload(payload.newRecord);
        }
        await loadCustomerNotificationsWithMode(silent: true);
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
      final int beforeLength = appointments.length;
      appointments = appointments.where((item) => item.id != appointmentId).toList();
      if (appointments.length != beforeLength) {
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
      notifyListeners();
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

class CustomerAppointmentSyncConflictException implements Exception {
  const CustomerAppointmentSyncConflictException();
}

class CustomerAppointmentAlreadyStartedException implements Exception {
  const CustomerAppointmentAlreadyStartedException();
}
