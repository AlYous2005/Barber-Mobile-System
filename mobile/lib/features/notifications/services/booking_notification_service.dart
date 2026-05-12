import '../repositories/notification_repository.dart';
import '../utils/notification_factory.dart';

class BookingNotificationService {
  const BookingNotificationService({
    this.notificationRepository = const NotificationRepository(),
  });

  final NotificationRepository notificationRepository;

  Future<void> notifyBarberAboutNewBooking({
    required String barberUserId,
    required String customerName,
    required String appointmentId,
  }) {
    final payload = NotificationFactory.newBookingForBarber(
      barberUserId: barberUserId,
      customerName: customerName,
      appointmentId: appointmentId,
    );

    return notificationRepository.createFromPayload(payload);
  }

  Future<void> notifyCustomerAboutAppointmentConfirmation({
    required String customerUserId,
    required String barberName,
    required String appointmentId,
  }) {
    final payload = NotificationFactory.appointmentConfirmedForCustomer(
      customerUserId: customerUserId,
      barberName: barberName,
      appointmentId: appointmentId,
    );

    return notificationRepository.createFromPayload(payload);
  }

  Future<void> notifyUserAboutAppointmentCancellation({
    required String receiverUserId,
    required String appointmentId,
    required String message,
  }) {
    final payload = NotificationFactory.appointmentCancelled(
      receiverUserId: receiverUserId,
      appointmentId: appointmentId,
      message: message,
    );

    return notificationRepository.createFromPayload(payload);
  }

  Future<void> notifyCustomerAboutAppointmentCompletion({
    required String customerUserId,
    required String barberName,
    required String appointmentId,
  }) {
    final payload = NotificationFactory.appointmentCompletedForCustomer(
      customerUserId: customerUserId,
      barberName: barberName,
      appointmentId: appointmentId,
    );

    return notificationRepository.createFromPayload(payload);
  }
}
