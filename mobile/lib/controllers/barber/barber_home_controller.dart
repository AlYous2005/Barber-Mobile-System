// appointments + filters + timeline state + menu state

import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../utils/appointment_status_utils.dart';
import '../../repositories/booking_repository.dart';
import '../../services/auth_session.dart';
import '../../data/mocks/mock_notifications.dart';

class BarberHomeController extends ChangeNotifier {
  BarberHomeController({
    BookingRepository bookingRepository = const BookingRepository(),
  }) : _bookingRepository = bookingRepository;

  final BookingRepository _bookingRepository;

  bool isLoadingAppointments = true;
  String? appointmentsErrorMessage;
  List<MockAppointment> barberAppointments = [];

  bool showCurrent = true;
  bool isMenuOpen = false;
  String barberDisplayName = 'يوسف';
  String selectedAppointmentFilter = 'معلقة';

  int get unreadNotifications {
    return mockBarberNotifications.where((item) => !item.isRead).length;
  }

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? 'b1';
  }

  Future<void> loadBarberAppointments() async {
    isLoadingAppointments = true;
    appointmentsErrorMessage = null;
    notifyListeners();

    try {
      final loaded = await _bookingRepository.getBarberAppointments(
        barberId: _currentBarberId,
      );

      barberAppointments = loaded;
      isLoadingAppointments = false;
      notifyListeners();
    } catch (_) {
      appointmentsErrorMessage = 'تعذر تحميل مواعيد الحلاق، حاول مرة أخرى';
      isLoadingAppointments = false;
      notifyListeners();
    }
  }

  MockAppointment? get currentTimelineAppointment {
    for (final appointment in barberAppointments) {
      if (appointment.isCurrent) {
        return appointment;
      }
    }

    return null;
  }

  MockAppointment? get upcomingTimelineAppointment {
    for (final appointment in barberAppointments) {
      if (appointment.isUpcoming) {
        return appointment;
      }
    }

    return null;
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
        return 'المواعيد المعلقة لليوم';
      case 'مؤكدة':
        return 'المواعيد المؤكدة لليوم';
      case 'مكتملة':
        return 'المواعيد المكتملة لليوم';
      case 'ملغية':
        return 'المواعيد الملغية لليوم';
      default:
        return 'كل مواعيد اليوم';
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

  void updateBarberDisplayName(String newName) {
    barberDisplayName = newName;
    notifyListeners();
  }
}
