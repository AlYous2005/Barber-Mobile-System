//

import 'package:flutter/material.dart';

import '../../models/working_day_model.dart';

class BarberWorkingHoursController extends ChangeNotifier {
  List<WorkingDay> workingDays = const [
    WorkingDay(
      dayKey: 'saturday',
      dayName: 'السبت',
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'sunday',
      dayName: 'الأحد',
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'monday',
      dayName: 'الإثنين',
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'tuesday',
      dayName: 'الثلاثاء',
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'wednesday',
      dayName: 'الأربعاء',
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'thursday',
      dayName: 'الخميس',
      startTime: '09:00',
      endTime: '18:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'friday',
      dayName: 'الجمعة',
      startTime: '00:00',
      endTime: '00:00',
      isActive: false,
    ),
  ];

  void updateWorkingDay(WorkingDay updatedDay) {
    workingDays = workingDays.map((item) {
      if (item.dayKey != updatedDay.dayKey) {
        return item;
      }

      return updatedDay;
    }).toList();

    notifyListeners();
  }

  String formatTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final time = TimeOfDay(hour: hour, minute: minute);
    final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final displayMinute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

    return '$displayHour:$displayMinute $period';
  }
}
