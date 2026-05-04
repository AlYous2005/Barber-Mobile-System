import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class AvailableTimesStep extends StatefulWidget {
  const AvailableTimesStep({
    super.key,
    required this.selectedTime,
    required this.selectedDateLabel,
    required this.requiredDurationLabel,
    required this.onSelectTime,
  });

  final String? selectedTime;
  final String selectedDateLabel;
  final String requiredDurationLabel;
  final ValueChanged<String> onSelectTime;

  @override
  State<AvailableTimesStep> createState() => _AvailableTimesStepState();
}

class _AvailableTimesStepState extends State<AvailableTimesStep> {
  String selectedPeriod = 'morning';

  static const List<String> morningTimes = [
    '10:00 صباحاً',
    '10:30 صباحاً',
    '11:00 صباحاً',
    '12:00 ظهراً',
  ];

  static const List<String> eveningTimes = [
    '04:00 مساءً',
    '05:30 مساءً',
    '06:00 مساءً',
    '07:00 مساءً',
  ];

  // Mock حاليًا: لاحقًا الباك إند هو الذي يحدد الأوقات غير المتاحة.
  static const Set<String> unavailableTimes = {'10:30 صباحاً', '06:00 مساءً'};

  List<String> get currentTimes {
    if (selectedPeriod == 'morning') {
      return morningTimes;
    }

    return eveningTimes;
  }

  String get currentTitle {
    if (selectedPeriod == 'morning') {
      return 'الأوقات الصباحية';
    }

    return 'الأوقات المسائية';
  }

  String get currentSubtitle {
    if (selectedPeriod == 'morning') {
      return 'اختر وقتًا مناسبًا قبل الظهيرة.';
    }

    return 'أوقات مناسبة بعد الظهر والمساء.';
  }

  IconData get currentIcon {
    if (selectedPeriod == 'morning') {
      return Icons.wb_sunny_rounded;
    }

    return Icons.nightlight_round_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AvailableTimesInfoCard(
          selectedDateLabel: widget.selectedDateLabel,
          requiredDurationLabel: widget.requiredDurationLabel,
          selectedTime: widget.selectedTime,
        ),

        const SizedBox(height: 16),

        _TimePeriodTabs(
          selectedPeriod: selectedPeriod,
          onChanged: (period) {
            setState(() {
              selectedPeriod = period;
            });
          },
        ),

        const SizedBox(height: 16),

        _TimesGroup(
          title: currentTitle,
          subtitle: currentSubtitle,
          icon: currentIcon,
          times: currentTimes,
          unavailableTimes: unavailableTimes,
          selectedTime: widget.selectedTime,
          onSelectTime: widget.onSelectTime,
        ),

        const SizedBox(height: 8),

        const _TimeSelectionHint(),
      ],
    );
  }
}

class _TimePeriodTabs extends StatelessWidget {
  const _TimePeriodTabs({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TimePeriodTabButton(
              title: 'صباحي',
              icon: Icons.wb_sunny_rounded,
              isSelected: selectedPeriod == 'morning',
              onTap: () => onChanged('morning'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TimePeriodTabButton(
              title: 'مسائي',
              icon: Icons.nightlight_round_rounded,
              isSelected: selectedPeriod == 'evening',
              onTap: () => onChanged('evening'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePeriodTabButton extends StatelessWidget {
  const _TimePeriodTabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFFC47A3D);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x22C47A3D),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : activeColor,
                size: 20,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppThemeColors.textSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AvailableTimesInfoCard extends StatelessWidget {
  const AvailableTimesInfoCard({
    super.key,
    required this.selectedDateLabel,
    required this.requiredDurationLabel,
    required this.selectedTime,
  });

  final String selectedDateLabel;
  final String requiredDurationLabel;
  final String? selectedTime;

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedTime = selectedTime != null;
    final bool dark = AppThemeColors.isDark(context);
    final List<Color> gradientColors = dark
        ? [
            AppThemeColors.elevatedCard(context),
            AppThemeColors.card(context),
            AppThemeColors.softCard(context),
          ]
        : const [Color(0xFFFFFFFF), Color(0xFFFFFBF7), Color(0xFFFFEDD5)];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasSelectedTime
              ? const Color(0xFFC47A3D)
              : AppThemeColors.border(context),
          width: hasSelectedTime ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasSelectedTime
                ? const Color(0x24C47A3D)
                : const Color(0x10000000),
            blurRadius: hasSelectedTime ? 22 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأوقات المتاحة لهذا اليوم',
                      style: TextStyle(
                        color: AppThemeColors.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selectedDateLabel,
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _TimeInfoMiniBox(
                  label: 'مدة الحجز',
                  value: requiredDurationLabel,
                  icon: Icons.timelapse_rounded,
                  color: const Color(0xFF2563EB),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _TimeInfoMiniBox(
                  label: 'الوقت المختار',
                  value: selectedTime ?? 'لم يتم الاختيار',
                  icon: Icons.check_circle_rounded,
                  color: hasSelectedTime
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeInfoMiniBox extends StatelessWidget {
  const _TimeInfoMiniBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey(value),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 15.5,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimesGroup extends StatelessWidget {
  const _TimesGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.times,
    required this.unavailableTimes,
    required this.selectedTime,
    required this.onSelectTime,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> times;
  final Set<String> unavailableTimes;
  final String? selectedTime;
  final ValueChanged<String> onSelectTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 7),
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
                  color: AppThemeColors.softCard(context),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFFC47A3D), size: 21),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppThemeColors.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          GridView.builder(
            itemCount: times.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.45,
            ),
            itemBuilder: (context, index) {
              final String time = times[index];
              final bool isUnavailable = unavailableTimes.contains(time);

              return _AvailableTimeCard(
                label: time,
                selected: selectedTime == time,
                unavailable: isUnavailable,
                onTap: isUnavailable ? null : () => onSelectTime(time),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AvailableTimeCard extends StatelessWidget {
  const _AvailableTimeCard({
    required this.label,
    required this.selected,
    required this.unavailable,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool unavailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppThemeColors.card(context);
    Color borderColor = AppThemeColors.border(context);
    Color textColor = AppThemeColors.textPrimary(context);
    Color iconColor = const Color(0xFFC47A3D);

    if (selected) {
      backgroundColor = const Color(0xFFC47A3D);
      borderColor = const Color(0xFFC47A3D);
      textColor = Colors.white;
      iconColor = Colors.white;
    }

    if (unavailable) {
      backgroundColor = AppThemeColors.softCard(context);
      borderColor = AppThemeColors.border(context);
      textColor = AppThemeColors.textMuted(context);
      iconColor = AppThemeColors.textMuted(context);
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x30C47A3D),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unavailable
                    ? Icons.block_rounded
                    : selected
                    ? Icons.check_circle_rounded
                    : Icons.access_time_rounded,
                color: iconColor,
                size: 17,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  unavailable ? 'محجوز' : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _TimeSelectionHint extends StatelessWidget {
  const _TimeSelectionHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFC47A3D), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الأوقات المحجوزة أو غير المتاحة تظهر باللون الرمادي. لاحقًا سيتم حسابها تلقائيًا حسب جدول الحلاق.',
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
