import '../widgets/customer/booking_date_selector.dart';

DateTime startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime resolveBookingDate(BookingDateChoice choice, DateTime? customDate) {
  final today = startOfDay(DateTime.now());

  switch (choice) {
    case BookingDateChoice.today:
      return today;
    case BookingDateChoice.tomorrow:
      return today.add(const Duration(days: 1));
    case BookingDateChoice.custom:
      return customDate != null ? startOfDay(customDate) : today;
  }
}

String resolveDateDisplayLabel(BookingDateChoice choice, DateTime resolvedDate) {
  switch (choice) {
    case BookingDateChoice.today:
      return 'اليوم';
    case BookingDateChoice.tomorrow:
      return 'غداً';
    case BookingDateChoice.custom:
      return '${resolvedDate.day}/${resolvedDate.month}/${resolvedDate.year}';
  }
}

String arabicDayName(DateTime date) {
  switch (date.weekday) {
    case DateTime.saturday:
      return 'السبت';
    case DateTime.sunday:
      return 'الأحد';
    case DateTime.monday:
      return 'الإثنين';
    case DateTime.tuesday:
      return 'الثلاثاء';
    case DateTime.wednesday:
      return 'الأربعاء';
    case DateTime.thursday:
      return 'الخميس';
    case DateTime.friday:
      return 'الجمعة';
    default:
      return '';
  }
}

String dateWithDayLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year - ${arabicDayName(date)}';
}