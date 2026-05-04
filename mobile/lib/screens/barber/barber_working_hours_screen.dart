import 'package:flutter/material.dart';

import '../../models/working_day_model.dart';
import '../../widgets/barber/working_hours/working_hours_intro_card.dart';
import '../../widgets/barber/working_hours/working_day_card.dart';
import '../../widgets/barber/working_hours/working_hours_edit_sheet.dart';

class BarberWorkingHoursScreen extends StatefulWidget {
  const BarberWorkingHoursScreen({super.key});

  @override
  State<BarberWorkingHoursScreen> createState() =>
      _BarberWorkingHoursScreenState();
}

class _BarberWorkingHoursScreenState extends State<BarberWorkingHoursScreen> {
  late List<WorkingDay> workingDays;

  @override
  void initState() {
    super.initState();

    workingDays = const [
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
  }

  void _openEditSheet(WorkingDay day) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WorkingHoursEditSheet(
          day: day,
          onSave: (updatedDay) {
            setState(() {
              workingDays = workingDays.map((item) {
                if (item.dayKey != updatedDay.dayKey) return item;
                return updatedDay;
              }).toList();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم حفظ ساعات عمل يوم ${updatedDay.dayName}'),
              ),
            );
          },
        );
      },
    );
  }
  
  static String _formatTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final time = TimeOfDay(hour: hour, minute: minute);
    final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final displayMinute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const WorkingHoursIntroCard(),

            const SizedBox(height: 16),

            ...workingDays.map(
              (day) => WorkingDayCard(
                day: day,
                formatTime: _formatTime,
                onEdit: () => _openEditSheet(day),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
