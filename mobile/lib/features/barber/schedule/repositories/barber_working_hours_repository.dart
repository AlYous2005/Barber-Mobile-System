import '../models/working_day_model.dart';
import '../../../../services/supabase_config.dart';

class BarberWorkingHoursRepository {
  const BarberWorkingHoursRepository();

  Future<List<WorkingDay>> getWorkingDays({required String barberId}) async {
    final rows = await SupabaseConfig.client
        .from('working_days')
        .select('day_of_week, start_time, end_time, is_active')
        .eq('barber_id', barberId)
        .order('day_of_week');

    if (rows.isEmpty) {
      return defaultWorkingDays;
    }

    final loadedDays = rows.map<WorkingDay>((row) {
      final dayOfWeek = _parseInt(row['day_of_week']);
      final dayInfo = _dayInfoFromNumber(dayOfWeek);

      return WorkingDay(
        dayKey: dayInfo.dayKey,
        dayName: dayInfo.dayName,
        dayOfWeek: dayOfWeek,
        startTime: _cleanTime(row['start_time']),
        endTime: _cleanTime(row['end_time']),
        isActive: row['is_active'] == true,
      );
    }).toList();

    return _mergeWithDefaultDays(loadedDays);
  }

  Future<WorkingDay> updateWorkingDay({
    required String barberId,
    required WorkingDay day,
  }) async {
    final row = await SupabaseConfig.client
        .from('working_days')
        .upsert({
          'barber_id': barberId,
          'day_of_week': day.dayOfWeek,
          'start_time': _timeForDatabase(day.startTime),
          'end_time': _timeForDatabase(day.endTime),
          'is_active': day.isActive,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'barber_id,day_of_week')
        .select('day_of_week, start_time, end_time, is_active')
        .single();

    final dayOfWeek = _parseInt(row['day_of_week']);
    final dayInfo = _dayInfoFromNumber(dayOfWeek);

    return WorkingDay(
      dayKey: dayInfo.dayKey,
      dayName: dayInfo.dayName,
      dayOfWeek: dayOfWeek,
      startTime: _cleanTime(row['start_time']),
      endTime: _cleanTime(row['end_time']),
      isActive: row['is_active'] == true,
    );
  }

  List<WorkingDay> _mergeWithDefaultDays(List<WorkingDay> loadedDays) {
    final loadedByDay = {for (final day in loadedDays) day.dayOfWeek: day};

    return defaultWorkingDays.map((defaultDay) {
      return loadedByDay[defaultDay.dayOfWeek] ?? defaultDay;
    }).toList();
  }

  String _timeForDatabase(String value) {
    final cleaned = _cleanTime(value);
    return '$cleaned:00';
  }

  String _cleanTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';

    if (raw.isEmpty) {
      return '09:00';
    }

    final parts = raw.split(':');
    final hour = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '09';
    final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';

    return '$hour:$minute';
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  _DayInfo _dayInfoFromNumber(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return const _DayInfo(dayKey: 'saturday', dayName: 'السبت');
      case 1:
        return const _DayInfo(dayKey: 'sunday', dayName: 'الأحد');
      case 2:
        return const _DayInfo(dayKey: 'monday', dayName: 'الإثنين');
      case 3:
        return const _DayInfo(dayKey: 'tuesday', dayName: 'الثلاثاء');
      case 4:
        return const _DayInfo(dayKey: 'wednesday', dayName: 'الأربعاء');
      case 5:
        return const _DayInfo(dayKey: 'thursday', dayName: 'الخميس');
      case 6:
        return const _DayInfo(dayKey: 'friday', dayName: 'الجمعة');
      default:
        return const _DayInfo(dayKey: 'saturday', dayName: 'السبت');
    }
  }

  static const List<WorkingDay> defaultWorkingDays = [
    WorkingDay(
      dayKey: 'saturday',
      dayName: 'السبت',
      dayOfWeek: 0,
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'sunday',
      dayName: 'الأحد',
      dayOfWeek: 1,
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'monday',
      dayName: 'الإثنين',
      dayOfWeek: 2,
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'tuesday',
      dayName: 'الثلاثاء',
      dayOfWeek: 3,
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'wednesday',
      dayName: 'الأربعاء',
      dayOfWeek: 4,
      startTime: '09:00',
      endTime: '21:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'thursday',
      dayName: 'الخميس',
      dayOfWeek: 5,
      startTime: '09:00',
      endTime: '18:00',
      isActive: true,
    ),
    WorkingDay(
      dayKey: 'friday',
      dayName: 'الجمعة',
      dayOfWeek: 6,
      startTime: '00:00',
      endTime: '00:01',
      isActive: false,
    ),
  ];
}

class _DayInfo {
  const _DayInfo({required this.dayKey, required this.dayName});

  final String dayKey;
  final String dayName;
}
