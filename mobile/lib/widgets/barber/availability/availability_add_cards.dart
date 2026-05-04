import 'package:flutter/material.dart';

import 'availability_shared_widgets.dart';

class ClosureAddCard extends StatelessWidget {
  const ClosureAddCard({
    super.key,
    required this.selectedDateLabel,
    required this.reasonController,
    required this.onPickDate,
    required this.onAdd,
    required this.onReset,
  });

  final String selectedDateLabel;
  final TextEditingController reasonController;
  final VoidCallback onPickDate;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AvailabilityAddCardShell(
      icon: Icons.add_rounded,
      title: 'إضافة يوم إغلاق',
      subtitle: 'أضف تاريخ الإغلاق مع السبب بطريقة مرتبة وواضحة',
      child: Column(
        children: [
          AvailabilityPickerBox(
            label: 'تاريخ الإغلاق',
            value: selectedDateLabel,
            icon: Icons.calendar_month_rounded,
            onTap: onPickDate,
          ),
          const SizedBox(height: 14),
          AvailabilityTextInputBox(
            label: 'سبب الإغلاق',
            hint: 'مثال: إجازة خاصة / ظرف طارئ',
            icon: Icons.info_rounded,
            controller: reasonController,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AvailabilityPrimaryButton(
                  label: 'إضافة يوم الإغلاق',
                  icon: Icons.add_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: onAdd,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AvailabilitySecondaryButton(
                  label: 'إعادة تعيين',
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimeBlockAddCard extends StatelessWidget {
  const TimeBlockAddCard({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    required this.selectedDateLabel,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.reasonController,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onAdd,
    required this.onReset,
  });

  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final String selectedDateLabel;
  final String startTimeLabel;
  final String endTimeLabel;
  final TextEditingController reasonController;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AvailabilityAddCardShell(
      icon: Icons.access_time_rounded,
      title: 'إضافة فترة عدم توفر',
      subtitle: 'استراحة متكررة أو فترة خاصة ليوم محدد داخل ساعات العمل',
      child: Column(
        children: [
          AvailabilityModeSwitch(
            selectedMode: selectedMode,
            onChanged: onModeChanged,
          ),
          const SizedBox(height: 14),
          if (selectedMode == 'specific')
            AvailabilityPickerBox(
              label: 'التاريخ',
              value: selectedDateLabel,
              icon: Icons.calendar_month_rounded,
              onTap: onPickDate,
            )
          else
            const AvailabilityInfoBox(
              text:
                  'تُطبَّق هذه الفترة تلقائيًا على كل يوم مفعّل في ساعات العمل.',
              icon: Icons.repeat_rounded,
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AvailabilityPickerBox(
                  label: 'من الساعة',
                  value: startTimeLabel,
                  icon: Icons.access_time_rounded,
                  onTap: onPickStartTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AvailabilityPickerBox(
                  label: 'إلى الساعة',
                  value: endTimeLabel,
                  icon: Icons.access_time_rounded,
                  onTap: onPickEndTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AvailabilityTextInputBox(
            label: 'السبب',
            hint: 'مثال: استراحة غداء',
            icon: Icons.info_rounded,
            controller: reasonController,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AvailabilityPrimaryButton(
                  label: 'إضافة الفترة',
                  icon: Icons.add_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: onAdd,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AvailabilitySecondaryButton(
                  label: 'إعادة تعيين',
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
