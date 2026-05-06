import '../models/booking_model.dart';
import '../models/mock_appointment.dart';
import '../utils/booking_formatters.dart';
import '../data/mocks/mock_appointments.dart';
import 'contracts/booking_repository_contract.dart';

class BookingRepository implements BookingRepositoryContract {
  const BookingRepository();

  static final List<MockAppointment> _createdAppointments = [];
  
  @override
  Future<List<MockAppointment>> getCustomerAppointments({
    required String customerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final createdForCustomer = _createdAppointments
        .where((appointment) => appointment.customerId == customerId)
        .toList();

    return [...mockCustomerAppointments, ...createdForCustomer];
  }
  @override
  Future<List<MockAppointment>> getBarberAppointments({
    required String barberId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final createdForBarber = _createdAppointments
        .where((appointment) => appointment.barberId == barberId)
        .toList();

    return [...mockBarberAppointments, ...createdForBarber];
  }
  @override
  Future<BookingModel> createBooking({
    required BookingModel booking,
    required String customerId,
    required String customerName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    final startDateTime = _resolveAppointmentStartDateTime(
      booking.date,
      booking.timeLabel,
    );

    final DateTime endDateTime = startDateTime.add(
      Duration(minutes: booking.service.durationMinutes),
    );

    final appointment = MockAppointment(
      id: 'created_${DateTime.now().microsecondsSinceEpoch}',
      customerId: customerId,
      barberId: booking.barber.id,
      customerName: customerName,
      barberName: booking.barber.name,
      barberRating: booking.barber.rating,
      serviceName: booking.service.name,
      dateLabel: booking.dateDisplayLabel,
      timeLabel: formatArabicAppointmentTimeRange(startDateTime, endDateTime),
      status: 'معلق',
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      createdAt: DateTime.now(),
    );

    _createdAppointments.add(appointment);

    return booking;
  }

  DateTime _resolveAppointmentStartDateTime(DateTime date, String timeLabel) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeLabel);

    if (match == null) {
      return date;
    }

    int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);

    final bool isMorning = timeLabel.contains('صباح');
    final bool isNoon = timeLabel.contains('ظهر');
    final bool isEvening = timeLabel.contains('مساء');

    if (isMorning && hour == 12) {
      hour = 0;
    }

    if ((isEvening || isNoon) && hour != 12) {
      hour += 12;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
