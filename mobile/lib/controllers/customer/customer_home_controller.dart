// state + appointments + profile + notifications

import 'package:flutter/material.dart';
import '../../repositories/notification_repository.dart';
import '../../models/barber_model.dart';
import '../../models/customer_profile_result.dart';
import '../../models/mock_appointment.dart';
import '../../models/mock_notification.dart';
import '../../repositories/barber_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../services/auth_session.dart';
import '../../utils/appointment_filters.dart';
import '../../repositories/customer_profile_repository.dart';

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

  bool isLoadingAppointments = true;
  String? appointmentsErrorMessage;

  String displayName = '';
  String countryCode = '+970';
  String phoneNumber = '599999999';
  String? avatarUrl;

  bool isNotificationsDropdownOpen = false;
  String selectedAppointmentsTab = 'upcoming';

  List<MockAppointment> appointments = [];
  List<MockNotification> customerNotifications = [];

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
    isLoadingAppointments = true;
    appointmentsErrorMessage = null;
    notifyListeners();

    try {
      final currentUser = AuthSession.currentUser;

      final loadedAppointments = await _bookingRepository
          .getCustomerAppointments(
            customerId: currentUser?.username ?? 'guest_customer',
          );

      appointments = loadedAppointments;
      isLoadingAppointments = false;
      notifyListeners();
    } catch (_) {
      appointmentsErrorMessage = 'تعذر تحميل المواعيد، حاول مرة أخرى';
      isLoadingAppointments = false;
      notifyListeners();
    }
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
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      customerNotifications = await _notificationRepository.getNotifications(
        userId: currentUser.username,
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('CustomerHomeController notifications load error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
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

    notifyListeners();
  }

  void toggleNotificationsDropdown() {
    isNotificationsDropdownOpen = !isNotificationsDropdownOpen;
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

  void cancelAppointmentLocally(MockAppointment appointment) {
    appointments = appointments.map((item) {
      if (item.id != appointment.id) {
        return item;
      }

      return item.copyWith(status: 'ملغي');
    }).toList();

    notifyListeners();
  }
}
