import '../utils/appointment_status_utils.dart';
import '../utils/booking_formatters.dart';
import 'appointment_cancelled_by.dart';

class MockAppointment {
  const MockAppointment({
    required this.id,
    required this.customerName,
    required this.barberName,
    required this.barberRating,
    required this.serviceName,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.startDateTime,
    required this.endDateTime,
    this.customerId,
    this.barberId,
    this.customerAvatarUrl,
    this.customerPhoneNumber,
    this.createdAt,
    this.cancelledBy,
    this.customerRating,
  });

  final String id;
  final String customerName;
  final String barberName;
  final double barberRating;
  final String serviceName;
  final String dateLabel;
  final String timeLabel;
  final String status;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? customerId;
  final String? barberId;
  final String? customerAvatarUrl;
  final String? customerPhoneNumber;

  /// When the customer confirmed the booking (not the appointment slot time).
  final DateTime? createdAt;

  /// Present when [status] is cancelled and DB stores [AppointmentColumnNames.cancelledBy].
  final AppointmentCancelledBy? cancelledBy;

  /// Rating submitted by the current customer for this appointment.
  /// Null means this appointment has not been rated yet.
  final int? customerRating;

  bool get isCompleted => AppointmentStatusUtils.isCompleted(status);
  bool get isCurrent => AppointmentStatusUtils.isCurrent(status);
  bool get isUpcoming => AppointmentStatusUtils.isUpcoming(status);

  String get displayTimeRange =>
      formatArabicAppointmentTimeRange(startDateTime, endDateTime);

  /// Visible customer name for barber-facing UI (never use [customerId] as name).
  String get displayCustomerName {
    final trimmed = customerName.trim();
    return trimmed.isNotEmpty ? trimmed : 'زبون جديد';
  }

  MockAppointment copyWith({
    String? id,
    String? customerName,
    String? barberName,
    double? barberRating,
    String? serviceName,
    String? dateLabel,
    String? timeLabel,
    String? status,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? customerId,
    String? barberId,
    DateTime? createdAt,
    String? customerAvatarUrl,
    String? customerPhoneNumber,
    AppointmentCancelledBy? cancelledBy,
    int? customerRating,
  }) {
    return MockAppointment(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      barberName: barberName ?? this.barberName,
      barberRating: barberRating ?? this.barberRating,
      serviceName: serviceName ?? this.serviceName,
      dateLabel: dateLabel ?? this.dateLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      status: status ?? this.status,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      customerId: customerId ?? this.customerId,
      barberId: barberId ?? this.barberId,
      createdAt: createdAt ?? this.createdAt,
      customerAvatarUrl: customerAvatarUrl ?? this.customerAvatarUrl,
      customerPhoneNumber: customerPhoneNumber ?? this.customerPhoneNumber,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      customerRating: customerRating ?? this.customerRating,
    );
  }
}
