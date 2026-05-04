import '../models/mock_appointment.dart';

bool isPreviousAppointment(MockAppointment appointment) {
  final now = DateTime.now();

  return appointment.status == 'مكتمل' ||
      appointment.status == 'ملغي' ||
      appointment.endDateTime.isBefore(now);
}

bool isUpcomingAppointment(MockAppointment appointment) {
  return !isPreviousAppointment(appointment);
}

bool canCancelAppointment(MockAppointment appointment) {
  return appointment.status == 'معلق' ||
      appointment.status == 'قادم' ||
      appointment.status == 'تم التأكيد';
}