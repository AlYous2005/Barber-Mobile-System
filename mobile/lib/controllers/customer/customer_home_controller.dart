// state + appointments + profile + notifications

import 'package:flutter/material.dart';

import '../../data/mocks/mock_notifications.dart';
import '../../models/barber_model.dart';
import '../../models/customer_profile_result.dart';
import '../../models/mock_appointment.dart';
import '../../models/mock_notification.dart';
import '../../repositories/barber_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../services/auth_session.dart';
import '../../utils/appointment_filters.dart';

class CustomerHomeController extends ChangeNotifier {
  CustomerHomeController({
    required String initialUserName,
    BookingRepository bookingRepository = const BookingRepository(),
    BarberRepository barberRepository = const BarberRepository(),
  }) : _bookingRepository = bookingRepository,
       _barberRepository = barberRepository {
    _initializeProfile(initialUserName);

    customerNotifications = List<MockNotification>.from(
      mockCustomerNotifications,
    );
  }

  final BookingRepository _bookingRepository;
  final BarberRepository _barberRepository;

  bool isLoadingAppointments = true;
  String? appointmentsErrorMessage;

  String displayName = '';
  String countryCode = '+970';
  String phoneNumber = '599999999';

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
      ),
    );
  }

  void markAllNotificationsAsRead() {
    if (unreadNotifications == 0) return;

    customerNotifications = customerNotifications
        .map(
          (item) => item.isRead
              ? item
              : MockNotification(
                  id: item.id,
                  message: item.message,
                  isRead: true,
                ),
        )
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
