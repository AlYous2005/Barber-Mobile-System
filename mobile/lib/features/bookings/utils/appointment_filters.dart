import '../bookings.dart';

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

bool hasAppointmentStarted(MockAppointment appointment) {
  return !DateTime.now().isBefore(appointment.startDateTime);
}

bool canCancelAppointment(MockAppointment appointment) {
  final bool statusAllowsCancel =
      AppointmentStatusUtils.isPending(appointment.status) ||
      AppointmentStatusUtils.isConfirmed(appointment.status);
  if (!statusAllowsCancel) {
    return false;
  }
  return !hasAppointmentStarted(appointment);
}
