import 'package:flutter/material.dart';

String formatArabicTime(String value) {
  final parts = value.split(':');
  final hour = int.tryParse(parts.first) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

  final time = TimeOfDay(hour: hour, minute: minute);
  final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final displayMinute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

  return '$displayHour:$displayMinute $period';
}

bool isStartTimeBeforeEndTime(String start, String end) {
  final int startMinutes = timeStringToMinutes(start);
  final int endMinutes = timeStringToMinutes(end);

  return startMinutes < endMinutes;
}

int timeStringToMinutes(String value) {
  final parts = value.split(':');

  final hour = int.tryParse(parts.first) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

  return (hour * 60) + minute;
}
