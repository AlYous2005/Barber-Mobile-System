import 'package:flutter/material.dart';

class AuthBirthDateSelector extends StatelessWidget {
  const AuthBirthDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.errorText,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? errorText;

  String get _formattedDate {
    if (selectedDate == null) {
      return "تاريخ الميلاد";
    }

    final day = selectedDate!.day.toString().padLeft(2, '0');
    final month = selectedDate!.month.toString().padLeft(2, '0');
    final year = selectedDate!.year.toString();

    return "$day/$month/$year";
  }

  void _openBirthDateSheet(BuildContext context) {
    final now = DateTime.now();

    int selectedDay = selectedDate?.day ?? 1;
    int selectedMonth = selectedDate?.month ?? 1;
    int selectedYear = selectedDate?.year ?? 2005;

    final int maxYear = now.year - 10;
    const int minYear = 1950;

    int daysInMonth(int year, int month) {
      return DateTime(year, month + 1, 0).day;
    }

    void normalizeDay() {
      final maxDay = daysInMonth(selectedYear, selectedMonth);
      if (selectedDay > maxDay) {
        selectedDay = maxDay;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final int maxDay = daysInMonth(selectedYear, selectedMonth);

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0.94, end: 1),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "اختر تاريخ الميلاد",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "اختر اليوم والشهر والسنة بطريقة سهلة",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _BirthDropdown(
                              label: "اليوم",
                              value: selectedDay,
                              items: List.generate(
                                maxDay,
                                (index) => index + 1,
                              ),
                              onChanged: (value) {
                                if (value == null) return;

                                setSheetState(() {
                                  selectedDay = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BirthDropdown(
                              label: "الشهر",
                              value: selectedMonth,
                              items: List.generate(12, (index) => index + 1),
                              onChanged: (value) {
                                if (value == null) return;

                                setSheetState(() {
                                  selectedMonth = value;
                                  normalizeDay();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BirthDropdown(
                              label: "السنة",
                              value: selectedYear,
                              items: List.generate(
                                maxYear - minYear + 1,
                                (index) => maxYear - index,
                              ),
                              onChanged: (value) {
                                if (value == null) return;

                                setSheetState(() {
                                  selectedYear = value;
                                  normalizeDay();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            onDateChanged(
                              DateTime(
                                selectedYear,
                                selectedMonth,
                                selectedDay,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: const Text(
                            "تأكيد التاريخ",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "إلغاء",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDate = selectedDate != null;
    final String? trimmedError = errorText?.trim();
    final bool showFieldError = trimmedError != null && trimmedError.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _openBirthDateSheet(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: showFieldError
                    ? const Color(0xFFFF7043)
                    : Colors.white.withValues(alpha: 0.12),
                width: showFieldError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: showFieldError
                      ? const Color(0xFFFF7043)
                      : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formattedDate,
                    style: TextStyle(
                      color: showFieldError
                          ? const Color(0xFFFFCCBC)
                          : hasDate
                              ? Colors.white
                              : Colors.white54,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: showFieldError
                      ? const Color(0xFFFF7043)
                      : Colors.orange,
                ),
              ],
            ),
          ),
        ),
        if (showFieldError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              trimmedError,
              style: const TextStyle(
                color: Color(0xFFFFCCBC),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BirthDropdown extends StatelessWidget {
  const _BirthDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFC66D),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              iconEnabledColor: Colors.orange,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
              items: items.map((item) {
                return DropdownMenuItem<int>(
                  value: item,
                  child: Text(item.toString().padLeft(2, '0')),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}