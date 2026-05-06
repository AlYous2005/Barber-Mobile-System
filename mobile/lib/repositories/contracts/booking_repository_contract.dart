import '../../models/booking_model.dart';
import '../../models/mock_appointment.dart';

abstract class BookingRepositoryContract {
  Future<List<MockAppointment>> getCustomerAppointments({
    required String customerId,
  });

  Future<List<MockAppointment>> getBarberAppointments({
    required String barberId,
  });

  Future<BookingModel> createBooking({
    required BookingModel booking,
    required String customerId,
    required String customerName,
  });
}