import 'booking_date_helpers.dart';

/// Stored in Supabase as [storageValue].
enum BookingWindowType {
  today('today'),
  todayTomorrow('today_tomorrow'),
  week('week'),
  month('month');

  const BookingWindowType(this.storageValue);

  final String storageValue;

  static BookingWindowType fromStorage(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return BookingWindowType.month;
    }
    final String v = raw.trim();
    for (final BookingWindowType t in BookingWindowType.values) {
      if (t.storageValue == v) return t;
    }
    return BookingWindowType.month;
  }
}

/// Builds the list of calendar dates a customer may book when the barber
/// enables a booking window. When [enabled] is false, returns an empty list
/// (caller should keep existing unrestricted UI).
class BookingWindowHelper {
  const BookingWindowHelper._();

  static List<DateTime> buildAllowedDates({
    required bool enabled,
    required BookingWindowType type,
    required DateTime now,
  }) {
    if (!enabled) {
      return const [];
    }

    final DateTime t = startOfDay(now);

    switch (type) {
      case BookingWindowType.today:
        return <DateTime>[t];
      case BookingWindowType.todayTomorrow:
        return <DateTime>[t, t.add(const Duration(days: 1))];
      case BookingWindowType.week:
        return List<DateTime>.generate(
          7,
          (int i) => t.add(Duration(days: i)),
        );
      case BookingWindowType.month:
        final DateTime end = DateTime(t.year, t.month + 2, 0);
        final List<DateTime> out = <DateTime>[];
        for (DateTime d = t; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
          out.add(d);
        }
        return out;
    }
  }
}
