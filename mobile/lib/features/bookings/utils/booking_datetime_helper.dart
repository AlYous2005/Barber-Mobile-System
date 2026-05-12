import 'booking_formatters.dart';

class BookingDateTimeHelper {
  const BookingDateTimeHelper._();

  static DateTime resolveAppointmentStartDateTime(
    DateTime date,
    String timeLabel,
  ) {
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

  static DateTime combineDateAndTime(dynamic dateValue, dynamic timeValue) {
    final String date = dateValue.toString();
    final String time = timeValue.toString();

    return DateTime.parse('${date}T$time');
  }

  static String formatDateForDatabase(DateTime dateTime) {
    final String year = dateTime.year.toString().padLeft(4, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String formatTimeForDatabase(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  static String formatDateLabel(DateTime dateTime) {
    final DateTime now = DateTime.now();

    final bool isToday =
        dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    final DateTime tomorrow = now.add(const Duration(days: 1));

    final bool isTomorrow =
        dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;

    if (isToday) {
      return 'اليوم';
    }

    if (isTomorrow) {
      return 'غدًا';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  static String formatAppointmentTimeRange(
    DateTime startDateTime,
    DateTime endDateTime,
  ) {
    return formatArabicAppointmentTimeRange(startDateTime, endDateTime);
  }
}
