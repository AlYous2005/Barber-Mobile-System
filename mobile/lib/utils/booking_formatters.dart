/// Clock like `10:30 صباحًا` (uses noon = مساءً for hour 12).
String formatArabicClockWithPeriod(DateTime dateTime) {
  final int hour = dateTime.hour;
  final int minute = dateTime.minute;
  final String period = hour >= 12 ? 'مساءً' : 'صباحًا';
  final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final String displayMinute = minute.toString().padLeft(2, '0');
  return '$displayHour:$displayMinute $period';
}

/// Range like `10:00 - 10:30 صباحًا` or `11:30 صباحًا - 12:15 مساءً`.
String formatArabicAppointmentTimeRange(DateTime start, DateTime end) {
  final String startPeriod = start.hour >= 12 ? 'مساءً' : 'صباحًا';
  final String endPeriod = end.hour >= 12 ? 'مساءً' : 'صباحًا';

  final int sh = start.hour;
  final int sm = start.minute;
  final int eh = end.hour;
  final int em = end.minute;

  final String startClock =
      '${sh % 12 == 0 ? 12 : sh % 12}:${sm.toString().padLeft(2, '0')}';
  final String endClock =
      '${eh % 12 == 0 ? 12 : eh % 12}:${em.toString().padLeft(2, '0')}';

  if (startPeriod == endPeriod) {
    return '$startClock - $endClock $startPeriod';
  }

  return '$startClock $startPeriod - $endClock $endPeriod';
}

String formatAppointmentBookedAtLine(DateTime createdAt) {
  return 'تم حجزه: ${formatArabicClockWithPeriod(createdAt)}';
}

String formatBookingDuration(int totalMinutes) {
  if (totalMinutes <= 0) {
    return '0';
  }

  if (totalMinutes < 60) {
    return '$totalMinutes دقيقة';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  String hourText;

  if (hours == 1) {
    hourText = 'ساعة';
  } else if (hours == 2) {
    hourText = 'ساعتين';
  } else {
    hourText = '$hours ساعات';
  }

  if (minutes == 0) {
    return hourText;
  }

  if (minutes == 15) {
    return '$hourText وربع';
  }

  if (minutes == 30) {
    return '$hourText ونصف';
  }

  if (minutes == 45) {
    return '$hourText و45 دقيقة';
  }

  return '$hourText و$minutes دقائق';
}
