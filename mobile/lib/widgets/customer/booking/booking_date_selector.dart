import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import '../../../features/bookings/bookings.dart';

class BookingDateSelector extends StatefulWidget {
  const BookingDateSelector({
    super.key,
    required this.choice,
    required this.customDate,
    required this.onChoiceChanged,
    required this.onCustomDateChanged,
    this.useBookingWindow = false,
    this.allowedBookingDates = const <DateTime>[],
    this.onBookingWindowDateSelected,
  });

  final BookingDateChoice choice;
  final DateTime? customDate;
  final ValueChanged<BookingDateChoice> onChoiceChanged;
  final ValueChanged<DateTime> onCustomDateChanged;

  /// When true and [allowedBookingDates] is non-empty, shows date chips only
  /// (barber-defined booking window).
  final bool useBookingWindow;
  final List<DateTime> allowedBookingDates;
  final ValueChanged<DateTime>? onBookingWindowDateSelected;

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

  bool _isAllowedBookingWindowDate(DateTime date) {
    return widget.allowedBookingDates.any((allowedDate) {
      return _isSameDay(allowedDate, date);
    });
  }

  bool get _isLongMonthBookingWindow {
    return widget.useBookingWindow && widget.allowedBookingDates.length > 8;
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
    if (widget.useBookingWindow && widget.allowedBookingDates.isNotEmpty) {
      final DateTime selected = resolveBookingDate(
        widget.choice,
        widget.customDate,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر يوم الموعد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          _BookingWindowHintCard(
            dates: widget.allowedBookingDates,
            today: today,
            isSameDay: _isSameDay,
          ),
          const SizedBox(height: 12),
          if (_isLongMonthBookingWindow)
            _MonthBookingWindowPicker(
              dates: widget.allowedBookingDates,
              selectedDate: selected,
              customDate: widget.customDate,
              isCalendarOpen: isCalendarOpen,
              today: today,
              isSameDay: _isSameDay,
              isAllowedDate: _isAllowedBookingWindowDate,
              arabicWeekdayName: _arabicDayName,
              dateLabel: _dateLabel,
              onToggleCalendar: () {
                setState(() {
                  isCalendarOpen = !isCalendarOpen;
                });
              },
              onDateSelected: (DateTime date) {
                if (!_isAllowedBookingWindowDate(date)) {
                  return;
                }

                widget.onBookingWindowDateSelected?.call(date);

                setState(() {
                  isCalendarOpen = false;
                  selectedDatePulseKey++;
                });
              },
            )
          else
            _ConstrainedDayCards(
              dates: widget.allowedBookingDates,
              selectedDate: selected,
              onDateSelected: (DateTime date) {
                widget.onBookingWindowDateSelected?.call(date);
              },
              isSameDay: _isSameDay,
              arabicWeekdayName: _arabicDayName,
              dateLabel: _dateLabel,
              today: today,
            ),
        ],
      );
    }

    final String selectedCustomLabel = widget.customDate == null
        ? 'لم يتم اختيار تاريخ محدد'
        : _customDateWithDayLabel(widget.customDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

class _BookingWindowHintCard extends StatelessWidget {
  const _BookingWindowHintCard({
    required this.dates,
    required this.today,
    required this.isSameDay,
  });

  final List<DateTime> dates;
  final DateTime today;
  final bool Function(DateTime a, DateTime b) isSameDay;

  String get _message {
    if (dates.length == 1 && isSameDay(dates.first, today)) {
      return 'هذا الحلاق يسمح لك بالحجز اليوم فقط.';
    }

    if (dates.length == 2 &&
        isSameDay(dates.first, today) &&
        isSameDay(dates[1], today.add(const Duration(days: 1)))) {
      return 'هذا الحلاق يسمح لك بالحجز اليوم وغدًا فقط.';
    }

    if (dates.length >= 6 && dates.length <= 8) {
      return 'هذا الحلاق يسمح لك بالحجز خلال الأسبوع الحالي.';
    }

    return 'هذا الحلاق يسمح لك بالحجز حتى نهاية الشهر الحالي.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFC47A3D).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFC47A3D),
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _message,
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12.8,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstrainedDayCards extends StatelessWidget {
  const _ConstrainedDayCards({
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isSameDay,
    required this.arabicWeekdayName,
    required this.dateLabel,
    required this.today,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime a, DateTime b) isSameDay;
  final String Function(DateTime date) arabicWeekdayName;
  final String Function(DateTime date) dateLabel;
  final DateTime today;

  String _mainLabelFor(DateTime date) {
    if (isSameDay(date, today)) {
      return 'اليوم';
    }

    if (isSameDay(date, today.add(const Duration(days: 1)))) {
      return 'غدًا';
    }

    return arabicWeekdayName(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: dates.map((DateTime date) {
        final bool selected = isSameDay(date, selectedDate);

        return _BookingWindowDateCard(
          date: date,
          title: _mainLabelFor(date),
          subtitle: dateLabel(date),
          selected: selected,
          onTap: () => onDateSelected(date),
        );
      }).toList(),
    );
  }
}

class _MonthBookingWindowPicker extends StatelessWidget {
  const _MonthBookingWindowPicker({
    required this.dates,
    required this.selectedDate,
    required this.customDate,
    required this.isCalendarOpen,
    required this.today,
    required this.isSameDay,
    required this.isAllowedDate,
    required this.arabicWeekdayName,
    required this.dateLabel,
    required this.onToggleCalendar,
    required this.onDateSelected,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final DateTime? customDate;
  final bool isCalendarOpen;
  final DateTime today;
  final bool Function(DateTime a, DateTime b) isSameDay;
  final bool Function(DateTime date) isAllowedDate;
  final String Function(DateTime date) arabicWeekdayName;
  final String Function(DateTime date) dateLabel;
  final VoidCallback onToggleCalendar;
  final ValueChanged<DateTime> onDateSelected;

  DateTime get tomorrow => today.add(const Duration(days: 1));

  DateTime? get _todayDate {
    for (final DateTime date in dates) {
      if (isSameDay(date, today)) {
        return date;
      }
    }

    return null;
  }

  DateTime? get _tomorrowDate {
    for (final DateTime date in dates) {
      if (isSameDay(date, tomorrow)) {
        return date;
      }
    }

    return null;
  }

  bool get _selectedIsTodayOrTomorrow {
    return isSameDay(selectedDate, today) || isSameDay(selectedDate, tomorrow);
  }

  String get _customSelectedLabel {
    if (_selectedIsTodayOrTomorrow) {
      return 'اختر يومًا آخر من الشهر الحالي';
    }

    return '${arabicWeekdayName(selectedDate)} - ${dateLabel(selectedDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime visibleMonth = DateTime(today.year, today.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_todayDate != null)
          _BookingWindowDateCard(
            date: _todayDate!,
            title: 'اليوم',
            subtitle: dateLabel(_todayDate!),
            selected: isSameDay(_todayDate!, selectedDate),
            onTap: () => onDateSelected(_todayDate!),
          ),

        if (_tomorrowDate != null)
          _BookingWindowDateCard(
            date: _tomorrowDate!,
            title: 'غدًا',
            subtitle: dateLabel(_tomorrowDate!),
            selected: isSameDay(_tomorrowDate!, selectedDate),
            onTap: () => onDateSelected(_tomorrowDate!),
          ),

        _BookingWindowCustomDateCard(
          selected: !_selectedIsTodayOrTomorrow,
          selectedLabel: _customSelectedLabel,
          isOpen: isCalendarOpen,
          onTap: onToggleCalendar,
        ),

        if (isCalendarOpen) ...[
          const SizedBox(height: 14),
          _ArabicCalendarCard(
            visibleMonth: visibleMonth,
            selectedDate: selectedDate,
            today: today,
            isSameDay: isSameDay,
            isPastDate: (DateTime date) {
              return date.isBefore(today) || !isAllowedDate(date);
            },
            onPreviousMonth: () {},
            onNextMonth: () {},
            onSelectDate: onDateSelected,
          ),
        ],
      ],
    );
  }
}

class _BookingWindowCustomDateCard extends StatelessWidget {
  const _BookingWindowCustomDateCard({
    required this.selected,
    required this.selectedLabel,
    required this.isOpen,
    required this.onTap,
  });

  final bool selected;
  final String selectedLabel;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFC47A3D);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? activeColor.withValues(alpha: 0.12)
            : AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? activeColor : AppThemeColors.border(context),
                width: selected ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? activeColor.withValues(alpha: 0.16)
                      : const Color(0x0D000000),
                  blurRadius: selected ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? activeColor
                        : activeColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.edit_calendar_rounded,
                    color: selected ? Colors.white : activeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختيار تاريخ محدد',
                        style: TextStyle(
                          color: selected
                              ? activeColor
                              : AppThemeColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedLabel,
                        style: TextStyle(
                          color: AppThemeColors.textSecondary(context),
                          fontSize: 12.7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: activeColor,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingWindowDateCard extends StatelessWidget {
  const _BookingWindowDateCard({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFC47A3D);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? activeColor.withValues(alpha: 0.12)
            : AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? activeColor : AppThemeColors.border(context),
                width: selected ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? activeColor.withValues(alpha: 0.16)
                      : const Color(0x0D000000),
                  blurRadius: selected ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? activeColor
                        : activeColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: selected ? Colors.white : activeColor,
                    size: 22,
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
                          color: selected
                              ? activeColor
                              : AppThemeColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppThemeColors.textSecondary(context),
                          fontSize: 12.7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? activeColor
                          : AppThemeColors.border(context),
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 21,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                width: 38,
                height: 38,
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
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
