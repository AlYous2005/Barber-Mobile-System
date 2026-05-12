import '../../barber/schedule/schedule.dart';
import '../models/mock_appointment.dart';

class ManualAppointmentSlotsHelper {
  const ManualAppointmentSlotsHelper._();

  static List<DateTime> buildAvailableSlots({
    required DateTime date,
    required int totalDurationMinutes,
    required List<WorkingDay> workingDays,
    required List<MockAppointment> existingAppointments,
    required List<ClosureDay> closures,
    required List<TimeBlock> timeBlocks,
    int stepMinutes = 15,
  }) {
    if (totalDurationMinutes <= 0) {
      return [];
    }

    final String dateLabel = _formatDateLabel(date);

    final bool isClosed = closures.any((closure) {
      return closure.dateLabel == dateLabel;
    });

    if (isClosed) {
      return [];
    }

    final int appDayOfWeek = _appDayOfWeek(date);

    final WorkingDay? workingDay = _findWorkingDay(
      workingDays: workingDays,
      dayOfWeek: appDayOfWeek,
    );

    if (workingDay == null || !workingDay.isActive) {
      return [];
    }

    final DateTime workStart = _combineDateAndTime(date, workingDay.startTime);
    final DateTime workEnd = _combineDateAndTime(date, workingDay.endTime);

    if (!workEnd.isAfter(workStart)) {
      return [];
    }

    final List<_BusyRange> busyRanges = [
      ...existingAppointments
          .where((appointment) => _isSameDate(appointment.startDateTime, date))
          .where((appointment) {
            final status = appointment.status.trim();

            return status != 'ملغي' && status != 'ملغية' && status != 'لم يحضر';
          })
          .map((appointment) {
            return _BusyRange(
              start: appointment.startDateTime,
              end: appointment.endDateTime,
            );
          }),
      ...timeBlocks
          .where((block) {
            if (block.dateLabel == null) {
              return true;
            }

            return block.dateLabel == dateLabel;
          })
          .map((block) {
            return _BusyRange(
              start: _combineDateAndTime(date, block.startTime),
              end: _combineDateAndTime(date, block.endTime),
            );
          }),
    ];

    final List<DateTime> slots = [];

    DateTime cursor = workStart;
    final DateTime latestStart = workEnd.subtract(
      Duration(minutes: totalDurationMinutes),
    );

    final DateTime now = DateTime.now();

    while (!cursor.isAfter(latestStart)) {
      final DateTime slotEnd = cursor.add(
        Duration(minutes: totalDurationMinutes),
      );

      final bool isPastSlot = _isSameDate(date, now) && cursor.isBefore(now);

      final bool overlaps = busyRanges.any((range) {
        return _overlaps(cursor, slotEnd, range.start, range.end);
      });

      if (!isPastSlot && !overlaps) {
        slots.add(cursor);
      }

      cursor = cursor.add(Duration(minutes: stepMinutes));
    }

    return slots;
  }

  static WorkingDay? _findWorkingDay({
    required List<WorkingDay> workingDays,
    required int dayOfWeek,
  }) {
    for (final day in workingDays) {
      if (day.dayOfWeek == dayOfWeek) {
        return day;
      }
    }

    return null;
  }

  static int _appDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return 0;
      case DateTime.sunday:
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 5;
      case DateTime.friday:
        return 6;
    }

    return 0;
  }

  static bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static bool _overlaps(
    DateTime firstStart,
    DateTime firstEnd,
    DateTime secondStart,
    DateTime secondEnd,
  ) {
    return firstStart.isBefore(secondEnd) && firstEnd.isAfter(secondStart);
  }

  static DateTime _combineDateAndTime(DateTime date, String time) {
    final parts = time.split(':');
    final int hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final int minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static String _formatDateLabel(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _BusyRange {
  const _BusyRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
