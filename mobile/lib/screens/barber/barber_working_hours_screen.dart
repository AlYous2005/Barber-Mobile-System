import 'package:flutter/material.dart';

class BarberWorkingHoursScreen extends StatefulWidget {
  const BarberWorkingHoursScreen({super.key});

  @override
  State<BarberWorkingHoursScreen> createState() =>
      _BarberWorkingHoursScreenState();
}

class _BarberWorkingHoursScreenState extends State<BarberWorkingHoursScreen> {
  late List<_WorkingDay> workingDays;

  @override
  void initState() {
    super.initState();

    workingDays = const [
      _WorkingDay(dayKey: 'saturday', dayName: 'السبت', startTime: '09:00', endTime: '21:00', isActive: true),
      _WorkingDay(dayKey: 'sunday', dayName: 'الأحد', startTime: '09:00', endTime: '21:00', isActive: true),
      _WorkingDay(dayKey: 'monday', dayName: 'الإثنين', startTime: '09:00', endTime: '21:00', isActive: true),
      _WorkingDay(dayKey: 'tuesday', dayName: 'الثلاثاء', startTime: '09:00', endTime: '21:00', isActive: true),
      _WorkingDay(dayKey: 'wednesday', dayName: 'الأربعاء', startTime: '09:00', endTime: '21:00', isActive: true),
      _WorkingDay(dayKey: 'thursday', dayName: 'الخميس', startTime: '09:00', endTime: '18:00', isActive: true),
      _WorkingDay(dayKey: 'friday', dayName: 'الجمعة', startTime: '00:00', endTime: '00:00', isActive: false),
    ];
  }

  void _openEditSheet(_WorkingDay day) {
    String editStartTime = day.startTime;
    String editEndTime = day.endTime;
    bool editIsActive = day.isActive;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void saveChanges() {
              setState(() {
                workingDays = workingDays.map((item) {
                  if (item.dayKey != day.dayKey) return item;

                  return item.copyWith(
                    startTime: editStartTime,
                    endTime: editEndTime,
                    isActive: editIsActive,
                  );
                }).toList();
              });

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حفظ ساعات عمل يوم ${day.dayName}'),
                ),
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC47A3D)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFC47A3D)
                                      .withValues(alpha: 0.18),
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_calendar_rounded,
                                color: Color(0xFFC47A3D),
                                size: 21,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'تعديل ساعات العمل',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    day.dayName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Material(
                              color: const Color(0xFFF5F5F4),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.of(context).pop(),
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBFA),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFE4ECE7),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'حالة اليوم',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      editIsActive
                                          ? 'هذا اليوم مفتوح للحجوزات'
                                          : 'هذا اليوم مغلق ولن تظهر فيه حجوزات',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Switch(
                                value: editIsActive,
                                activeThumbColor: const Color(0xFF16A34A),
                                onChanged: (value) {
                                  setSheetState(() {
                                    editIsActive = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        if (editIsActive) ...[
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _TimePickerBox(
                                  label: 'وقت البداية',
                                  value: editStartTime,
                                  onTap: () async {
                                    final picked = await _pickTime(
                                      context: context,
                                      initialValue: editStartTime,
                                    );

                                    if (picked == null) return;

                                    setSheetState(() {
                                      editStartTime = picked;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _TimePickerBox(
                                  label: 'وقت النهاية',
                                  value: editEndTime,
                                  onTap: () async {
                                    final picked = await _pickTime(
                                      context: context,
                                      initialValue: editEndTime,
                                    );

                                    if (picked == null) return;

                                    setSheetState(() {
                                      editEndTime = picked;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.timer_off_rounded,
                                  color: Color(0xFFB91C1C),
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'عند حفظ التعديلات سيتم اعتبار هذا اليوم مغلقًا بالكامل.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.6,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: _PrimaryActionButton(
                                label: 'حفظ التعديلات',
                                icon: Icons.save_rounded,
                                onTap: saveChanges,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _SecondaryActionButton(
                                label: 'إلغاء',
                                icon: Icons.close_rounded,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<String?> _pickTime({
    required BuildContext context,
    required String initialValue,
  }) async {
    final parts = initialValue.split(':');
    final hour = int.tryParse(parts.first) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (picked == null) return null;

    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
            const _WorkingHoursIntroCard(),

            const SizedBox(height: 16),

            ...workingDays.map(
              (day) => _WorkingDayCard(
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

class _WorkingHoursIntroCard extends StatelessWidget {
  const _WorkingHoursIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6E3F2F),
            Color(0xFF9B5A3D),
            Color(0xFFC37A49),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WorkingHoursCenterPill(),

          SizedBox(height: 14),

          Text(
            'ساعات العمل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'حدد أيام وساعات دوام الحلاق لتظهر للزبائن بشكل صحيح',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkingHoursCenterPill extends StatelessWidget {
  const _WorkingHoursCenterPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Working Hours Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.schedule_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkingDayCard extends StatelessWidget {
  const _WorkingDayCard({
    required this.day,
    required this.formatTime,
    required this.onEdit,
  });

  final _WorkingDay day;
  final String Function(String value) formatTime;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final bool isOpen = day.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEDF1F3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7F1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDCEFE2),
                  ),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF5C4030),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  day.dayName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              _DayStatusBadge(isOpen: isOpen),
            ],
          ),

          const SizedBox(height: 16),

          if (isOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFBFFFC),
                    Color(0xFFF5FBF7),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE3EFE7),
                ),
              ),
              child: Column(
                children: [
                  _HourRow(
                    label: 'من',
                    value: formatTime(day.startTime),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFDCEFE2),
                    ),
                  ),

                  _HourRow(
                    label: 'إلى',
                    value: formatTime(day.endTime),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF7F7),
                    Color(0xFFFEF2F2),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF8D3D3),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.timer_off_rounded,
                    color: Color(0xFFB91C1C),
                    size: 28,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'هذا اليوم مغلق',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: _EditDayButton(
              onTap: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayStatusBadge extends StatelessWidget {
  const _DayStatusBadge({
    required this.isOpen,
  });

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? const [
                  Color(0xFFDCFCE7),
                  Color(0xFFBBF7D0),
                ]
              : const [
                  Color(0xFFFEE2E2),
                  Color(0xFFFECACA),
                ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isOpen ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isOpen ? const Color(0xFF166534) : const Color(0xFF991B1B),
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'مفتوح' : 'مغلق',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color:
                  isOpen ? const Color(0xFF166534) : const Color(0xFF991B1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _EditDayButton extends StatelessWidget {
  const _EditDayButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2563EB),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color(0x292563EB),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 17,
              ),
              SizedBox(width: 8),
              Text(
                'تعديل',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerBox extends StatelessWidget {
  const _TimePickerBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  String _formatTime(String value) {
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
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),

        const SizedBox(height: 9),

        Material(
          color: const Color(0xFFF9FBFA),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4ECE7),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF5C4030),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatTime(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC47A3D),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF374151),
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkingDay {
  const _WorkingDay({
    required this.dayKey,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  final String dayKey;
  final String dayName;
  final String startTime;
  final String endTime;
  final bool isActive;

  _WorkingDay copyWith({
    String? startTime,
    String? endTime,
    bool? isActive,
  }) {
    return _WorkingDay(
      dayKey: dayKey,
      dayName: dayName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }
}