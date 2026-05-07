// loading + filtering + appointments state

import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../repositories/booking_repository.dart';
import '../../services/auth_session.dart';
import '../../utils/appointment_status_utils.dart';

class BarberAppointmentsController extends ChangeNotifier {
  BarberAppointmentsController({
    BookingRepository bookingRepository = const BookingRepository(),
  }) : _bookingRepository = bookingRepository;

  final BookingRepository _bookingRepository;

  bool isLoadingAppointments = true;
  String? appointmentsErrorMessage;

  List<MockAppointment> appointments = [];

  String selectedTab = 'today';

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> loadBarberAppointments() async {
    isLoadingAppointments = true;
    appointmentsErrorMessage = null;
    notifyListeners();

    try {
      if (_currentBarberId.isEmpty) {
        throw Exception('Missing current barber id');
      }

      final loadedAppointments = await _bookingRepository.getBarberAppointments(
        barberId: _currentBarberId,
      );

      appointments = loadedAppointments;
      isLoadingAppointments = false;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('BarberAppointmentsController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      appointmentsErrorMessage = 'تعذر تحميل مواعيد الحلاق، حاول مرة أخرى';
      isLoadingAppointments = false;
      notifyListeners();
    }
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
    notifyListeners();
  }

  Future<void> updateStatus(String id, String status) async {
    await _bookingRepository.updateAppointmentStatus(
      appointmentId: id,
      status: status,
    );

    appointments = appointments
        .map((item) => item.id == id ? item.copyWith(status: status) : item)
        .toList();

    notifyListeners();
  }

  void addManualAppointment(MockAppointment appointment) {
    appointments = [appointment, ...appointments];
    notifyListeners();
  }
}
