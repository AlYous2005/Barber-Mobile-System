import '../../../barber/services_management/services_management.dart';
import '../../models/appointment_status_actor.dart';
import '../../models/booking_model.dart';
import '../../models/selected_booking_service.dart';
import '../../models/barber_home_appointment_counts.dart';
import '../../models/mock_appointment.dart';

abstract class BookingRepositoryContract {
  Future<List<MockAppointment>> getCustomerAppointments({
    required String customerId,
    int? limit,
    int offset = 0,
  });

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    AppointmentStatusActor actor = AppointmentStatusActor.system,
  });

  Future<void> createAppointmentReview({
    required String barberId,
    required String customerId,
    required String appointmentId,
    required int rating,
  });

  /// Appointments linked to [serviceId] under [barberId] whose status is not terminal.
  Future<int> countActiveAppointmentsForService({
    required String barberId,
    required String serviceId,
  });

  /// Cancels (sets status ملغي) all such appointments from the barber side.
  Future<void> cancelActiveAppointmentsForService({
    required String barberId,
    required String serviceId,
  });

  Future<List<MockAppointment>> getBarberAppointments({
    required String barberId,
    int? limit,
    int offset = 0,

    /// When [limit] is set, use ascending date/time order for stable barber-home
    /// card pagination (oldest chunk first). Default is descending for other screens.
    bool chronologicalAscendingPagination = false,
  });

  /// Single appointment row for this barber (e.g. realtime INSERT merge on barber home).
  Future<MockAppointment?> getBarberAppointmentByIdForBarber({
    required String barberId,
    required String appointmentId,
  });

  /// Status totals for barber home stats (full database counts, not list-derived).
  Future<BarberHomeAppointmentCounts> getBarberHomeAppointmentCounts({
    required String barberId,
  });

  /// Confirmed appointment whose [startDateTime, endDateTime) contains [now], if any.
  Future<MockAppointment?> getBarberCurrentTimelineAppointment({
    required String barberId,
    required DateTime now,
  });

  /// Nearest confirmed appointment with start strictly after [now], if any.
  Future<MockAppointment?> getBarberUpcomingTimelineAppointment({
    required String barberId,
    required DateTime now,
  });

  Future<List<MockAppointment>> getBarberAppointmentsForDate({
    required String barberId,
    required DateTime date,
  });

  Future<BookingModel> createBooking({
    required BookingModel booking,
    required List<SelectedBookingService> selectedServices,
    required String customerId,
    required String customerName,
  });

  Future<MockAppointment> createManualAppointment({
    required String barberId,
    required String customerName,
    required List<ServiceModel> services,
    required DateTime startDateTime,
  });
}
