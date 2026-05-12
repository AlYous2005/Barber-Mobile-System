import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class AvailableTimesStep extends StatefulWidget {
  const AvailableTimesStep({
    super.key,
    required this.selectedTime,
    required this.selectedDateLabel,
    required this.requiredDurationLabel,
    required this.availableTimes,
    required this.isLoadingTimes,
    required this.message,
    required this.onSelectTime,
  });

  final String? selectedTime;
  final String selectedDateLabel;
  final String requiredDurationLabel;
  final List<String> availableTimes;
  final bool isLoadingTimes;
  final String? message;
  final ValueChanged<String> onSelectTime;

  @override
  State<AvailableTimesStep> createState() => _AvailableTimesStepState();
}

class _AvailableTimesStepState extends State<AvailableTimesStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimesGroup(
          title: 'الأوقات المتاحة',
          subtitle:
              '${widget.selectedDateLabel} • مدة الموعد ${widget.requiredDurationLabel}',
          icon: Icons.access_time_filled_rounded,
          times: widget.availableTimes,
          isLoading: widget.isLoadingTimes,
          message: widget.message,
          selectedTime: widget.selectedTime,
          onSelectTime: widget.onSelectTime,
        ),
      ],
    );
  }
}

class _TimesGroup extends StatelessWidget {
  const _TimesGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.times,
    required this.isLoading,
    required this.message,
    required this.selectedTime,
    required this.onSelectTime,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> times;
  final bool isLoading;
  final String? message;
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

          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
            )
          else if (message != null && message!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
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
                return _AvailableTimeCard(
                  label: time,
                  selected: selectedTime == time,
                  onTap: () => onSelectTime(time),
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
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
                selected
                    ? Icons.check_circle_rounded
                    : Icons.access_time_rounded,
                color: iconColor,
                size: 17,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
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
