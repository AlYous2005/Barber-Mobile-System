import '../constants/notification_constants.dart';
import '../models/notification_payload.dart';

class NotificationFactory {
  const NotificationFactory._();

  static NotificationPayload newBookingForBarber({
    required String barberUserId,
    required String customerName,
    required String appointmentId,
  }) {
    return NotificationPayload(
      userId: barberUserId,
      type: NotificationTypes.appointment,
      title: 'حجز جديد',
      message: 'لديك حجز جديد من $customerName',
      relatedEntityType: NotificationRelatedEntityTypes.appointment,
      relatedEntityId: appointmentId,
    );
  }

  static NotificationPayload appointmentConfirmedForCustomer({
    required String customerUserId,
    required String barberName,
    required String appointmentId,
  }) {
    return NotificationPayload(
      userId: customerUserId,
      type: NotificationTypes.appointment,
      title: 'تم تأكيد الموعد',
      message: 'تم تأكيد موعدك مع $barberName',
      relatedEntityType: NotificationRelatedEntityTypes.appointment,
      relatedEntityId: appointmentId,
    );
  }

  static NotificationPayload appointmentCancelled({
    required String receiverUserId,
    required String appointmentId,
    required String message,
  }) {
    return NotificationPayload(
      userId: receiverUserId,
      type: NotificationTypes.appointment,
      title: 'تم إلغاء الموعد',
      message: message,
      relatedEntityType: NotificationRelatedEntityTypes.appointment,
      relatedEntityId: appointmentId,
    );
  }

  static NotificationPayload appointmentCompletedForCustomer({
    required String customerUserId,
    required String barberName,
    required String appointmentId,
  }) {
    return NotificationPayload(
      userId: customerUserId,
      type: NotificationTypes.appointment,
      title: 'تم اكتمال الموعد',
      message:
          'اكتمل موعدك مع الحلاق $barberName، شكرًا على التزامك ويمكنك تقييمه الآن',
      relatedEntityType: NotificationRelatedEntityTypes.appointment,
      relatedEntityId: appointmentId,
    );
  }
}
