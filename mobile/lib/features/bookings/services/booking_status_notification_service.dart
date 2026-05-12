import '../models/appointment_status_actor.dart';
import '../../../services/supabase_config.dart';
import '../../notifications/notifications.dart';
import '../constants/booking_constants.dart';

class BookingStatusNotificationService {
  const BookingStatusNotificationService({
    this.bookingNotificationService = const BookingNotificationService(),
  });

  final BookingNotificationService bookingNotificationService;

  Future<void> notifyAfterStatusChange({
    required String appointmentId,
    required String databaseStatus,
    required Map<String, dynamic>? appointmentRow,
    required AppointmentStatusActor actor,
  }) async {
    if (databaseStatus == AppointmentStatuses.confirmed) {
      await _notifyCustomerAboutAppointmentConfirmation(
        appointmentId: appointmentId,
        appointmentRow: appointmentRow,
      );
    }

    if (databaseStatus == AppointmentStatuses.completed) {
      await _notifyCustomerAboutAppointmentCompletion(
        appointmentId: appointmentId,
        appointmentRow: appointmentRow,
      );
    }

    if (databaseStatus == AppointmentStatuses.cancelled) {
      await _notifyUserAboutAppointmentCancellation(
        appointmentId: appointmentId,
        appointmentRow: appointmentRow,
        actor: actor,
      );
    }
  }

  Future<void> notifyBarberAboutNewBooking({
    required String barberId,
    required String customerName,
    required String appointmentId,
  }) async {
    await _safeSendNotification(() async {
      final String? barberProfileId = await _getBarberProfileId(barberId);

      if (barberProfileId == null) {
        return;
      }

      await bookingNotificationService.notifyBarberAboutNewBooking(
        barberUserId: barberProfileId,
        customerName: customerName,
        appointmentId: appointmentId,
      );
    });
  }

  Future<void> _notifyCustomerAboutAppointmentConfirmation({
    required String appointmentId,
    required Map<String, dynamic>? appointmentRow,
  }) async {
    await _safeSendNotification(() async {
      if (appointmentRow == null) {
        return;
      }

      final String customerId =
          appointmentRow[AppointmentColumnNames.customerId]?.toString() ?? '';

      final String barberId =
          appointmentRow[AppointmentColumnNames.barberId]?.toString() ?? '';

      if (customerId.isEmpty || barberId.isEmpty) {
        return;
      }

      final String barberName = await _getBarberName(barberId);

      await bookingNotificationService
          .notifyCustomerAboutAppointmentConfirmation(
            customerUserId: customerId,
            barberName: barberName,
            appointmentId: appointmentId,
          );
    });
  }

  Future<void> _notifyCustomerAboutAppointmentCompletion({
    required String appointmentId,
    required Map<String, dynamic>? appointmentRow,
  }) async {
    await _safeSendNotification(() async {
      if (appointmentRow == null) {
        return;
      }

      final String customerId =
          appointmentRow[AppointmentColumnNames.customerId]?.toString() ?? '';

      final String barberId =
          appointmentRow[AppointmentColumnNames.barberId]?.toString() ?? '';

      if (customerId.isEmpty || barberId.isEmpty) {
        return;
      }

      final String barberName = await _getBarberName(barberId);

      await bookingNotificationService.notifyCustomerAboutAppointmentCompletion(
        customerUserId: customerId,
        barberName: barberName,
        appointmentId: appointmentId,
      );
    });
  }

  Future<void> _notifyUserAboutAppointmentCancellation({
    required String appointmentId,
    required Map<String, dynamic>? appointmentRow,
    required AppointmentStatusActor actor,
  }) async {
    await _safeSendNotification(() async {
      if (appointmentRow == null) {
        return;
      }

      final String customerId =
          appointmentRow[AppointmentColumnNames.customerId]?.toString() ?? '';

      final String barberId =
          appointmentRow[AppointmentColumnNames.barberId]?.toString() ?? '';

      if (customerId.isEmpty || barberId.isEmpty) {
        return;
      }

      String? receiverUserId;

      if (actor == AppointmentStatusActor.barber) {
        receiverUserId = customerId;
      }

      if (actor == AppointmentStatusActor.customer) {
        receiverUserId = await _getBarberProfileId(barberId);
      }

      if (receiverUserId == null || receiverUserId.isEmpty) {
        return;
      }

      final String barberName = await _getBarberName(barberId);

      final String message = _appointmentCancellationMessage(
        actor: actor,
        barberName: barberName,
      );

      await bookingNotificationService.notifyUserAboutAppointmentCancellation(
        receiverUserId: receiverUserId,
        appointmentId: appointmentId,
        message: message,
      );
    });
  }

  String _appointmentCancellationMessage({
    required AppointmentStatusActor actor,
    required String barberName,
  }) {
    switch (actor) {
      case AppointmentStatusActor.barber:
        return 'تم إلغاء موعدك من قبل الحلاق $barberName، يمكنك مراجعته إن أردت';

      case AppointmentStatusActor.customer:
        return 'قام الزبون بإلغاء الموعد';

      case AppointmentStatusActor.system:
        return 'تم إلغاء الموعد';
    }
  }

  Future<String?> _getBarberProfileId(String barberId) async {
    final barberRow = await SupabaseConfig.client
        .from(BookingTableNames.barbers)
        .select(BookingBarberColumnNames.profileId)
        .eq(BookingBarberColumnNames.id, barberId)
        .maybeSingle();

    final String? profileId = barberRow?[BookingBarberColumnNames.profileId]
        ?.toString()
        .trim();

    if (profileId == null || profileId.isEmpty) {
      return null;
    }

    return profileId;
  }

  Future<String> _getBarberName(String barberId) async {
    final barberRow = await SupabaseConfig.client
        .from(BookingTableNames.barbers)
        .select(BookingBarberColumnNames.name)
        .eq(BookingBarberColumnNames.id, barberId)
        .maybeSingle();

    final String barberName =
        barberRow?[BookingBarberColumnNames.name]?.toString().trim() ?? '';

    return barberName.isEmpty ? 'الحلاق' : barberName;
  }

  Future<void> _safeSendNotification(
    Future<void> Function() sendNotification,
  ) async {
    try {
      await sendNotification();
    } catch (_) {
      // لا نريد فشل الإشعار يكسر إنشاء/تحديث الموعد.
    }
  }
}
