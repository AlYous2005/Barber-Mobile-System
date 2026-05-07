// appointments + filters + timeline state + menu state

import 'package:flutter/material.dart';

import '../../data/mocks/mock_notifications.dart';
import '../../models/mock_appointment.dart';
import '../../repositories/booking_repository.dart';
import '../../services/auth_session.dart';
import '../../utils/appointment_status_utils.dart';
import '../../repositories/barber_avatar_repository.dart';

class BarberHomeController extends ChangeNotifier {
  BarberHomeController({
    BookingRepository bookingRepository = const BookingRepository(),
    BarberAvatarRepository barberAvatarRepository =
        const BarberAvatarRepository(),
  }) : _bookingRepository = bookingRepository,
       _barberAvatarRepository = barberAvatarRepository;

  final BookingRepository _bookingRepository;
  final BarberAvatarRepository _barberAvatarRepository;

  bool isLoadingAppointments = true;
  String? appointmentsErrorMessage;
  List<MockAppointment> barberAppointments = [];

  bool showCurrent = true;
  bool isMenuOpen = false;
  String barberDisplayName = 'يوسف';
  String? barberAvatarUrl;
  String selectedAppointmentFilter = 'معلقة';

  int get unreadNotifications {
    return mockBarberNotifications.where((item) => !item.isRead).length;
  }

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
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
    await _bookingRepository.updateAppointmentStatus(
      appointmentId: appointmentId,
      status: status,
    );

    barberAppointments = barberAppointments.map((appointment) {
      if (appointment.id != appointmentId) {
        return appointment;
      }

      return appointment.copyWith(status: status);
    }).toList();

    notifyListeners();
  }

  Future<void> loadBarberAppointments() async {
    isLoadingAppointments = true;
    appointmentsErrorMessage = null;
    notifyListeners();

    try {
      if (_currentBarberId.isEmpty) {
        throw Exception('Missing current barber id');
      }

      final loaded = await _bookingRepository.getBarberAppointments(
        barberId: _currentBarberId,
      );

      barberAppointments = loaded;
      isLoadingAppointments = false;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('BarberHomeController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      appointmentsErrorMessage = 'تعذر تحميل مواعيد الحلاق، حاول مرة أخرى';
      isLoadingAppointments = false;
      notifyListeners();
    }
  }

  List<MockAppointment> get confirmedAppointments {
    return barberAppointments.where((appointment) {
      return AppointmentStatusUtils.isConfirmed(appointment.status);
    }).toList();
  }

  MockAppointment? get currentTimelineAppointment {
    final DateTime now = DateTime.now();

    for (final appointment in confirmedAppointments) {
      final bool hasStarted = !appointment.startDateTime.isAfter(now);
      final bool hasNotEnded = appointment.endDateTime.isAfter(now);

      if (hasStarted && hasNotEnded) {
        return appointment;
      }
    }

    return null;
  }

  MockAppointment? get upcomingTimelineAppointment {
    final DateTime now = DateTime.now();

    final upcoming =
        confirmedAppointments.where((appointment) {
          return appointment.startDateTime.isAfter(now);
        }).toList()..sort((first, second) {
          return first.startDateTime.compareTo(second.startDateTime);
        });

    if (upcoming.isEmpty) {
      return null;
    }

    return upcoming.first;
  }

  int get pendingAppointmentsCount {
    return barberAppointments.where((appointment) {
      return AppointmentStatusUtils.isPending(appointment.status);
    }).length;
  }

  int get confirmedAppointmentsCount {
    return barberAppointments.where((appointment) {
      return AppointmentStatusUtils.isConfirmed(appointment.status);
    }).length;
  }

  int get completedAppointmentsCount {
    return barberAppointments.where((appointment) {
      return AppointmentStatusUtils.isCompleted(appointment.status);
    }).length;
  }

  int get cancelledAppointmentsCount {
    return barberAppointments.where((appointment) {
      return AppointmentStatusUtils.isCancelled(appointment.status);
    }).length;
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

  void updateBarberDisplayName(String newName) {
    barberDisplayName = newName;
    notifyListeners();
  }
}
