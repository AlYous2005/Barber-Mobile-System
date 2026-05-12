/// Aggregate appointment counts for the barber home stats row (not tied to a loaded list).
class BarberHomeAppointmentCounts {
  const BarberHomeAppointmentCounts({
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.noShow,
  });

  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;
  final int noShow;

  static const BarberHomeAppointmentCounts empty = BarberHomeAppointmentCounts(
    pending: 0,
    confirmed: 0,
    completed: 0,
    cancelled: 0,
    noShow: 0,
  );
}
