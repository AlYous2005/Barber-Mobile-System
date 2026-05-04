import 'package:flutter/material.dart';

import '../../../models/working_day_model.dart';
import '../../../utils/app_theme_colors.dart';

class WorkingDayCard extends StatelessWidget {
  const WorkingDayCard({
    super.key,
    required this.day,
    required this.formatTime,
    required this.onEdit,
  });

  final WorkingDay day;
  final String Function(String value) formatTime;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final bool isOpen = day.isActive;
    final bool dark = AppThemeColors.isDark(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
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
                  color: AppThemeColors.softCard(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppThemeColors.border(context)),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppThemeColors.brandBrown(context),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  day.dayName,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),

              DayStatusBadge(isOpen: isOpen),
            ],
          ),

          const SizedBox(height: 16),

          if (isOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: dark ? AppThemeColors.softCard(context) : null,
                gradient: dark
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFBFFFC), Color(0xFFF5FBF7)],
                      ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Column(
                children: [
                  HourRow(label: 'من', value: formatTime(day.startTime)),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      color: AppThemeColors.border(context),
                    ),
                  ),

                  HourRow(label: 'إلى', value: formatTime(day.endTime)),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF7F7), Color(0xFFFEF2F2)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF8D3D3)),
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
            child: EditDayButton(onTap: onEdit),
          ),
        ],
      ),
    );
  }
}

class DayStatusBadge extends StatelessWidget {
  const DayStatusBadge({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? const [Color(0xFFDCFCE7), Color(0xFFBBF7D0)]
              : const [Color(0xFFFEE2E2), Color(0xFFFECACA)],
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
              color: isOpen ? const Color(0xFF166534) : const Color(0xFF991B1B),
            ),
          ),
        ],
      ),
    );
  }
}

class HourRow extends StatelessWidget {
  const HourRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppThemeColors.textSecondary(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: AppThemeColors.textPrimary(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class EditDayButton extends StatelessWidget {
  const EditDayButton({super.key, required this.onTap});

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
              Icon(Icons.edit_rounded, color: Colors.white, size: 17),
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
