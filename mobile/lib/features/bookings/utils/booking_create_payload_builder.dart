import '../models/booking_model.dart';
import '../models/selected_booking_service.dart';
import '../constants/booking_constants.dart';
import 'booking_datetime_helper.dart';
import '../../barber/services_management/models/service_target.dart';

class BookingCreatePayload {
  const BookingCreatePayload({
    required this.appointmentData,
    required this.startDateTime,
    required this.endDateTime,
    required this.totalDuration,
    required this.totalPrice,
  });

  final Map<String, dynamic> appointmentData;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int totalDuration;
  final int totalPrice;
}

class BookingCreatePayloadBuilder {
  const BookingCreatePayloadBuilder._();

  static BookingCreatePayload buildAppointmentData({
    required BookingModel booking,
    required List<SelectedBookingService> selectedServices,
    required String customerId,
  }) {
    final DateTime startDateTime =
        BookingDateTimeHelper.resolveAppointmentStartDateTime(
          booking.date,
          booking.timeLabel,
        );

    final int totalDuration = selectedServices.fold(
      0,
      (sum, selected) => sum + selected.durationMinutes,
    );

    final int totalPrice = selectedServices.fold(
      0,
      (sum, selected) => sum + selected.price,
    );

    final DateTime endDateTime = startDateTime.add(
      Duration(minutes: totalDuration),
    );

    return BookingCreatePayload(
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      totalDuration: totalDuration,
      totalPrice: totalPrice,
      appointmentData: {
        AppointmentColumnNames.customerId: customerId,
        AppointmentColumnNames.barberId: booking.barber.id,
        AppointmentColumnNames.appointmentDate:
            BookingDateTimeHelper.formatDateForDatabase(startDateTime),
        AppointmentColumnNames.startTime:
            BookingDateTimeHelper.formatTimeForDatabase(startDateTime),
        AppointmentColumnNames.endTime:
            BookingDateTimeHelper.formatTimeForDatabase(endDateTime),
        AppointmentColumnNames.status: AppointmentStatuses.pending,
        AppointmentColumnNames.totalPrice: totalPrice,
        AppointmentColumnNames.totalDurationMinutes: totalDuration,
        AppointmentColumnNames.checkedIn: false,
        AppointmentColumnNames.reminderSent: false,
        AppointmentColumnNames.noShowMarked: false,
      },
    );
  }

  static List<Map<String, dynamic>> buildServiceRows({
    required String appointmentId,
    required List<SelectedBookingService> selectedServices,
  }) {
    return selectedServices.map((selected) {
      return {
        AppointmentServiceColumnNames.appointmentId: appointmentId,
        AppointmentServiceColumnNames.serviceId: selected.service.id,
        AppointmentServiceColumnNames.serviceNameSnapshot:
            selected.service.name,
        AppointmentServiceColumnNames.priceSnapshot: selected.price,
        AppointmentServiceColumnNames.durationMinutesSnapshot:
            selected.durationMinutes,
        AppointmentServiceColumnNames.serviceTarget:
            selected.target.databaseValue,
      };
    }).toList();
  }
}
