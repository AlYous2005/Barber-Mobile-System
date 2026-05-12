import 'package:flutter/material.dart';

import '../../general_utils/app_theme_colors.dart';

/// Shows the app-wide wheel date picker bottom sheet (RTL, [AppThemeColors]).
///
/// [minSelectableDate] and [maxSelectableDate] are normalized to midnight (date only).
/// If [minSelectableDate] is null, today (local) is used.
/// If [maxSelectableDate] is null, the last day of the month that is 11 months after
/// [min]'s month is used (same 12-month window as the manual appointment flow).
Future<DateTime?> showAppDatePickerSheet({
  required BuildContext context,
  DateTime? initialDate,
  String title = 'اختر التاريخ',
  String subtitle = 'اختر الشهر واليوم بالسحب',
  DateTime? minSelectableDate,
  DateTime? maxSelectableDate,
}) {
  final DateTime now = DateTime.now();
  final DateTime minD = _stripToDate(
    minSelectableDate ?? DateTime(now.year, now.month, now.day),
  );
  final DateTime defaultMax = DateTime(minD.year, minD.month + 12, 0);
  final DateTime maxD = _stripToDate(maxSelectableDate ?? defaultMax);
  final DateTime safeMax = minD.isAfter(maxD) ? minD : maxD;

  return showModalBottomSheet<DateTime>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AppDatePickerSheet(
        minDate: minD,
        maxDate: safeMax,
        initialDate: initialDate,
        title: title,
        subtitle: subtitle,
      );
    },
  );
}

DateTime _stripToDate(DateTime d) => DateTime(d.year, d.month, d.day);

List<DateTime> _monthsBetweenInclusive(DateTime minDay, DateTime maxDay) {
  final DateTime start = DateTime(minDay.year, minDay.month);
  final DateTime end = DateTime(maxDay.year, maxDay.month);
  final List<DateTime> months = [];
  DateTime cursor = start;
  while (!cursor.isAfter(end)) {
    months.add(cursor);
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
  return months;
}

class AppDatePickerSheet extends StatefulWidget {
  const AppDatePickerSheet({
    super.key,
    required this.minDate,
    required this.maxDate,
    this.initialDate,
    required this.title,
    required this.subtitle,
  });

  final DateTime minDate;
  final DateTime maxDate;
  final DateTime? initialDate;
  final String title;
  final String subtitle;

  @override
  State<AppDatePickerSheet> createState() => _AppDatePickerSheetState();
}

class _AppDatePickerSheetState extends State<AppDatePickerSheet> {
  late final List<DateTime> _months;
  late final FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  late int _selectedMonthIndex;
  late List<int> _availableDays;
  late int _selectedDay;

  DateTime get _clampedInitial {
    final DateTime base = widget.initialDate ?? widget.minDate;
    final DateTime d = DateTime(base.year, base.month, base.day);
    if (d.isBefore(widget.minDate)) return widget.minDate;
    if (d.isAfter(widget.maxDate)) return widget.maxDate;
    return d;
  }

  @override
  void initState() {
    super.initState();

    _months = _monthsBetweenInclusive(widget.minDate, widget.maxDate);
    if (_months.isEmpty) {
      _months.add(DateTime(widget.minDate.year, widget.minDate.month));
    }

    final DateTime initial = _clampedInitial;

    _selectedMonthIndex = _months.indexWhere(
      (m) => m.year == initial.year && m.month == initial.month,
    );
    final int safeMonthIndex =
        _selectedMonthIndex < 0 ? 0 : _selectedMonthIndex;

    _selectedMonthIndex = safeMonthIndex;
    _availableDays = _daysForMonth(_months[_selectedMonthIndex]);
    _selectedDay = _initialSelectedDay(initial);

    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonthIndex,
    );

    _dayController = FixedExtentScrollController(
      initialItem: _availableDays
          .indexOf(_selectedDay)
          .clamp(0, _availableDays.length - 1),
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  int _initialSelectedDay(DateTime initial) {
    final DateTime selectedMonth = _months[_selectedMonthIndex];
    final bool sameMonth =
        selectedMonth.year == initial.year &&
        selectedMonth.month == initial.month;

    if (!sameMonth) {
      return _availableDays.first;
    }

    if (_availableDays.contains(initial.day)) {
      return initial.day;
    }

    return _availableDays.first;
  }

  List<int> _daysForMonth(DateTime monthDate) {
    final int lastDayOfMonth = DateTime(
      monthDate.year,
      monthDate.month + 1,
      0,
    ).day;

    final DateTime monthStart = DateTime(monthDate.year, monthDate.month, 1);
    final DateTime monthEnd = DateTime(
      monthDate.year,
      monthDate.month,
      lastDayOfMonth,
    );

    int first = 1;
    if (!widget.minDate.isBefore(monthStart) &&
        widget.minDate.isBefore(monthEnd.add(const Duration(days: 1)))) {
      if (widget.minDate.year == monthDate.year &&
          widget.minDate.month == monthDate.month) {
        first = widget.minDate.day;
      }
    }

    int last = lastDayOfMonth;
    if (widget.maxDate.year == monthDate.year &&
        widget.maxDate.month == monthDate.month) {
      last = widget.maxDate.day;
    }

    if (first > last) {
      return [first];
    }

    return List.generate(last - first + 1, (index) => first + index);
  }

  void _onMonthChanged(int index) {
    final DateTime month = _months[index];
    final List<int> newDays = _daysForMonth(month);

    final int newSelectedDay = newDays.contains(_selectedDay)
        ? _selectedDay
        : newDays.first;

    _dayController.dispose();
    _dayController = FixedExtentScrollController(
      initialItem: newDays.indexOf(newSelectedDay),
    );

    setState(() {
      _selectedMonthIndex = index;
      _availableDays = newDays;
      _selectedDay = newSelectedDay;
    });
  }

  void _onDayChanged(int index) {
    setState(() {
      _selectedDay = _availableDays[index];
    });
  }

  DateTime get _selectedDate {
    final DateTime month = _months[_selectedMonthIndex];
    return DateTime(month.year, month.month, _selectedDay);
  }

  String _dayName(DateTime date) {
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
    }
    return '';
  }

  String _numericDateLabel(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  String _selectedDateLabel() {
    final DateTime date = _selectedDate;
    return '${_dayName(date)} | ${_numericDateLabel(date)}';
  }

  void _confirmDate() {
    Navigator.of(context).pop(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime selectedMonth = _months[_selectedMonthIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: AppThemeColors.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppThemeColors.border(context),
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
                    color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFC47A3D).withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFFC47A3D),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppThemeColors.softCard(context),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    color: AppThemeColors.brandBrown(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedDateLabel(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _DateWheelColumn(
                      title: 'الشهر',
                      controller: _monthController,
                      itemCount: _months.length,
                      itemBuilder: (index) {
                        final DateTime month = _months[index];
                        return '${month.month}-${month.year}';
                      },
                      onSelectedItemChanged: _onMonthChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateWheelColumn(
                      key: ValueKey(
                        '${selectedMonth.year}-${selectedMonth.month}',
                      ),
                      title: 'اليوم',
                      controller: _dayController,
                      itemCount: _availableDays.length,
                      itemBuilder: (index) {
                        final int day = _availableDays[index];
                        final DateTime date = DateTime(
                          selectedMonth.year,
                          selectedMonth.month,
                          day,
                        );

                        return '${_dayName(date)} | ${_numericDateLabel(date)}';
                      },
                      onSelectedItemChanged: _onDayChanged,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmDate,
                icon: const Icon(Icons.check_rounded),
                label: const Text('تأكيد التاريخ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC47A3D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateWheelColumn extends StatelessWidget {
  const _DateWheelColumn({
    super.key,
    required this.title,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
  });

  final String title;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) itemBuilder;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.brandBrown(context),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 46,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppThemeColors.brandBrown(
                      context,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppThemeColors.brandBrown(
                        context,
                      ).withValues(alpha: 0.35),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 44,
                  diameterRatio: 1.3,
                  perspective: 0.002,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: onSelectedItemChanged,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: itemCount,
                    builder: (context, index) {
                      if (index < 0 || index >= itemCount) {
                        return null;
                      }

                      return Center(
                        child: Text(
                          itemBuilder(index),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
