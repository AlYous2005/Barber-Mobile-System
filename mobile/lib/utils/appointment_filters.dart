import '../models/mock_appointment.dart';
import 'appointment_status_utils.dart';

bool isPreviousAppointment(MockAppointment appointment) {
  return AppointmentStatusUtils.isCompleted(appointment.status) ||
      AppointmentStatusUtils.isCancelled(appointment.status) ||
      AppointmentStatusUtils.isNoShow(appointment.status);
}

bool isUpcomingAppointment(MockAppointment appointment) {
  return AppointmentStatusUtils.isPending(appointment.status) ||
      AppointmentStatusUtils.isConfirmed(appointment.status) ||
      AppointmentStatusUtils.isCurrent(appointment.status);
}

bool canCancelAppointment(MockAppointment appointment) {
  return AppointmentStatusUtils.isPending(appointment.status) ||
      AppointmentStatusUtils.isConfirmed(appointment.status);
}
