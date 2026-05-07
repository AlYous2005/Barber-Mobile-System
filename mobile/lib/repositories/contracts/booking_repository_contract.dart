import '../../models/booking_model.dart';
import '../../models/mock_appointment.dart';
import '../../models/selected_booking_service.dart';

abstract class BookingRepositoryContract {
  Future<List<MockAppointment>> getCustomerAppointments({
    required String customerId,
  });

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  });

  Future<List<MockAppointment>> getBarberAppointments({
    required String barberId,
  });

  Future<BookingModel> createBooking({
    required BookingModel booking,
    required List<SelectedBookingService> selectedServices,
    required String customerId,
    required String customerName,
  });
}
