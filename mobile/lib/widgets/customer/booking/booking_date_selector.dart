import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

enum BookingDateChoice { today, tomorrow, custom }

class BookingDateSelector extends StatefulWidget {
  const BookingDateSelector({
    super.key,
    required this.choice,
    required this.customDate,
    required this.onChoiceChanged,
    required this.onCustomDateChanged,
  });

  final BookingDateChoice choice;
  final DateTime? customDate;
  final ValueChanged<BookingDateChoice> onChoiceChanged;
  final ValueChanged<DateTime> onCustomDateChanged;

  @override
  State<BookingDateSelector> createState() => _BookingDateSelectorState();
}

class _BookingDateSelectorState extends State<BookingDateSelector> {
  late DateTime visibleMonth;
  bool isCalendarOpen = false;
  int selectedDatePulseKey = 0;
  @override
  void initState() {
    super.initState();

    final DateTime baseDate = widget.customDate ?? DateTime.now();
    visibleMonth = DateTime(baseDate.year, baseDate.month);
  }

  DateTime get today {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get tomorrow {
    return today.add(const Duration(days: 1));
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _arabicDayName(DateTime date) {
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

  String _customDateWithDayLabel(DateTime date) {
    return '${_dateLabel(date)} - ${_arabicDayName(date)}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPastDate(DateTime date) {
    return date.isBefore(today);
  }

  void _goToPreviousMonth() {
    final DateTime previousMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month - 1,
    );

    final DateTime currentMonth = DateTime(today.year, today.month);

    if (previousMonth.isBefore(currentMonth)) return;

    setState(() {
      visibleMonth = previousMonth;
    });
  }

  void _goToNextMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    });
  }

  void _selectCustomDate(DateTime date) {
    if (_isPastDate(date)) return;

    widget.onChoiceChanged(BookingDateChoice.custom);
    widget.onCustomDateChanged(date);

    setState(() {
      isCalendarOpen = false;
      selectedDatePulseKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String selectedCustomLabel = widget.customDate == null
        ? 'لم يتم اختيار تاريخ محدد'
        : _customDateWithDayLabel(widget.customDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateChoiceHeader(
          title: 'اختر تاريخ الموعد',
          subtitle:
              'حدد اليوم المناسب لك، ويمكنك اختيار تاريخ محدد من التقويم.',
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _DateChoiceCard(
                label: 'اليوم',
                subtitle: _dateLabel(today),
                icon: Icons.today_rounded,
                selected: widget.choice == BookingDateChoice.today,
                onTap: () {
                  setState(() {
                    isCalendarOpen = false;
                  });
                  widget.onChoiceChanged(BookingDateChoice.today);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateChoiceCard(
                label: 'غدًا',
                subtitle: _dateLabel(tomorrow),
                icon: Icons.event_available_rounded,
                selected: widget.choice == BookingDateChoice.tomorrow,
                onTap: () {
                  setState(() {
                    isCalendarOpen = false;
                  });
                  widget.onChoiceChanged(BookingDateChoice.tomorrow);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _CustomDateTriggerCard(
          selected: widget.choice == BookingDateChoice.custom,
          selectedLabel: selectedCustomLabel,
          pulseKey: selectedDatePulseKey,
          onTap: () {
            if (widget.choice == BookingDateChoice.custom) {
              setState(() {
                isCalendarOpen = !isCalendarOpen;
              });
              return;
            }

            setState(() {
              isCalendarOpen = true;
            });

            widget.onChoiceChanged(BookingDateChoice.custom);
          },
        ),

        if (widget.choice == BookingDateChoice.custom && isCalendarOpen) ...[
          const SizedBox(height: 14),
          _ArabicCalendarCard(
            visibleMonth: visibleMonth,
            selectedDate: widget.customDate,
            today: today,

            isSameDay: _isSameDay,
            isPastDate: _isPastDate,
            onPreviousMonth: _goToPreviousMonth,
            onNextMonth: _goToNextMonth,
            onSelectDate: _selectCustomDate,
          ),
        ],
      ],
    );
  }
}

class _DateChoiceHeader extends StatelessWidget {
  const _DateChoiceHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppThemeColors.textSecondary(context),
                    fontSize: 12.8,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChoiceCard extends StatelessWidget {
  const _DateChoiceCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFFC47A3D)
                  : AppThemeColors.border(context),
              width: selected ? 1.7 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0x22C47A3D)
                    : const Color(0x0D000000),
                blurRadius: selected ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 190),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFC47A3D)
                      : AppThemeColors.softCard(context),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : const Color(0xFFC47A3D),
                  size: 21,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDateTriggerCard extends StatelessWidget {
  const _CustomDateTriggerCard({
    required this.selected,
    required this.selectedLabel,
    required this.pulseKey,
    required this.onTap,
  });

  final bool selected;
  final String selectedLabel;
  final int pulseKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedDate = selectedLabel != 'لم يتم اختيار تاريخ محدد';

    return TweenAnimationBuilder<double>(
      key: ValueKey('custom-date-pulse-$pulseKey'),
      tween: Tween<double>(begin: hasSelectedDate ? 1 : 0, end: 0),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, pulseValue, child) {
        final Color glowColor = const Color(0xFFC47A3D);
        final double glowOpacity = 0.22 * pulseValue;
        final double scale = 1 + (0.018 * pulseValue);

        return Transform.scale(
          scale: scale,
          child: Material(
            color: AppThemeColors.card(context),
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 190),
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFC47A3D)
                        : AppThemeColors.border(context),
                    width: selected ? 1.7 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(
                        alpha: selected ? 0.14 + glowOpacity : 0.06,
                      ),
                      blurRadius: selected ? 18 + (14 * pulseValue) : 10,
                      spreadRadius: 1.5 * pulseValue,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 190),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFC47A3D)
                            : AppThemeColors.softCard(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        hasSelectedDate
                            ? Icons.event_available_rounded
                            : Icons.edit_calendar_rounded,
                        color: selected
                            ? Colors.white
                            : const Color(0xFFC47A3D),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاريخ محدد',
                            style: TextStyle(
                              color: AppThemeColors.textPrimary(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.25),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              selectedLabel,
                              key: ValueKey(selectedLabel),
                              style: TextStyle(
                                color: hasSelectedDate
                                    ? const Color(0xFFC47A3D)
                                    : AppThemeColors.textSecondary(context),
                                fontSize: hasSelectedDate ? 13.5 : 12.5,
                                fontWeight: hasSelectedDate
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      selected
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFFC47A3D),
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArabicCalendarCard extends StatelessWidget {
  const _ArabicCalendarCard({
    required this.visibleMonth,
    required this.selectedDate,
    required this.today,

    required this.isSameDay,
    required this.isPastDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  final DateTime visibleMonth;
  final DateTime? selectedDate;
  final DateTime today;

  final bool Function(DateTime a, DateTime b) isSameDay;
  final bool Function(DateTime date) isPastDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  List<DateTime?> _buildCalendarDays() {
    final DateTime firstDayOfMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month,
      1,
    );

    final int daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;

    // Dart weekday: Monday = 1, Sunday = 7
    // We want week to start from Saturday.
    final int leadingEmptyDays = firstDayOfMonth.weekday == DateTime.saturday
        ? 0
        : firstDayOfMonth.weekday == DateTime.sunday
        ? 1
        : firstDayOfMonth.weekday + 1;

    final List<DateTime?> days = [
      ...List<DateTime?>.filled(leadingEmptyDays, null),
      ...List.generate(
        daysInMonth,
        (index) => DateTime(visibleMonth.year, visibleMonth.month, index + 1),
      ),
    ];

    while (days.length % 7 != 0) {
      days.add(null);
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime?> days = _buildCalendarDays();

    const weekdays = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MonthArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: onPreviousMonth,
              ),
              Expanded(
                child: Text(
                  'شهر (${visibleMonth.month}) - ${visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _MonthArrowButton(
                icon: Icons.chevron_left_rounded,
                onTap: onNextMonth,
              ),
            ],
          ),

          const SizedBox(height: 14),

          GridView.builder(
            itemCount: weekdays.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  weekdays[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeColors.textMuted(context),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 5),

          GridView.builder(
            itemCount: days.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final DateTime? date = days[index];

              if (date == null) {
                return const SizedBox.shrink();
              }

              final bool isSelected =
                  selectedDate != null && isSameDay(date, selectedDate!);

              final bool isToday = isSameDay(date, today);
              final bool disabled = isPastDate(date);

              return _CalendarDayCell(
                day: date.day,
                isSelected: isSelected,
                isToday: isToday,
                disabled: disabled,
                onTap: () => onSelectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.softCard(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: const Color(0xFFC47A3D), size: 24),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.disabled,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;
    Color textColor = AppThemeColors.textPrimary(context);
    Color borderColor = Colors.transparent;

    if (disabled) {
      textColor = AppThemeColors.textMuted(context);
    }

    if (isToday && !isSelected) {
      backgroundColor = AppThemeColors.softCard(context);
      borderColor = AppThemeColors.border(context);
      textColor = const Color(0xFFC47A3D);
    }

    if (isSelected) {
      backgroundColor = const Color(0xFFC47A3D);
      borderColor = const Color(0xFFC47A3D);
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
