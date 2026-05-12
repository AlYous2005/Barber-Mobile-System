class BookingTableNames {
  const BookingTableNames._();

  static const appointments = 'appointments';
  static const appointmentServices = 'appointment_services';
  static const profiles = 'profiles';
  static const barbers = 'barbers';
  static const barberReviews = 'barber_reviews';
}

class AppointmentColumnNames {
  const AppointmentColumnNames._();

  static const id = 'id';
  static const customerId = 'customer_id';
  static const manualCustomerName = 'manual_customer_name';
  static const barberId = 'barber_id';
  static const appointmentDate = 'appointment_date';
  static const startTime = 'start_time';
  static const endTime = 'end_time';
  static const status = 'status';
  static const totalPrice = 'total_price';
  static const totalDurationMinutes = 'total_duration_minutes';
  static const checkedIn = 'checked_in';
  static const reminderSent = 'reminder_sent';
  static const noShowMarked = 'no_show_marked';
  static const createdAt = 'created_at';

  /// Optional: who initiated cancellation (`barber` | `customer` | `system`). See SQL migration.
  static const cancelledBy = 'cancelled_by';
}

class AppointmentServiceColumnNames {
  const AppointmentServiceColumnNames._();

  static const appointmentId = 'appointment_id';
  static const serviceId = 'service_id';
  static const serviceNameSnapshot = 'service_name_snapshot';
  static const priceSnapshot = 'price_snapshot';
  static const durationMinutesSnapshot = 'duration_minutes_snapshot';
  static const serviceTarget = 'service_target';
  static const createdAt = 'created_at';
}

class BookingProfileColumnNames {
  const BookingProfileColumnNames._();

  static const firstName = 'first_name';
  static const lastName = 'last_name';
  static const phoneNumber = 'phone_number';
  static const avatarUrl = 'avatar_url';
}

class BookingBarberColumnNames {
  const BookingBarberColumnNames._();

  static const id = 'id';
  static const profileId = 'profile_id';
  static const name = 'name';
  static const rating = 'rating';
}

class BarberReviewColumnNames {
  const BarberReviewColumnNames._();

  static const id = 'id';
  static const barberId = 'barber_id';
  static const customerId = 'customer_id';
  static const appointmentId = 'appointment_id';
  static const rating = 'rating';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

class AppointmentStatuses {
  const AppointmentStatuses._();

  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const noShow = 'no_show';
}

/// Default page size when loading appointment lists with pagination.
class AppointmentPaging {
  const AppointmentPaging._();

  static const int pageSize = 20;
}
