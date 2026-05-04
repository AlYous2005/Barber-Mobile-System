import 'package:flutter/material.dart';

import '../../../models/mock_appointment.dart';
import '../../../utils/app_theme_colors.dart';

class HomeAppointmentCard extends StatelessWidget {
  const HomeAppointmentCard({
    super.key,
    required this.appointment,
    required this.onMarkCompleted,
    required this.onCancel,
  });

  final MockAppointment appointment;
  final VoidCallback onMarkCompleted;
  final VoidCallback onCancel;

  bool get _isFinal {
    return appointment.status == 'مكتمل' ||
        appointment.status == 'مكتملة' ||
        appointment.status == 'ملغي' ||
        appointment.status == 'ملغية' ||
        appointment.status == 'لم يحضر';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeAppointmentStatusBadge(status: appointment.status),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAECE0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x33C8A078)),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF5C4030),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appointment.customerName,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          HomeAppointmentDetailLine(
            icon: Icons.content_cut_rounded,
            text: appointment.serviceName,
          ),

          const SizedBox(height: 10),

          HomeAppointmentDetailLine(
            icon: Icons.access_time_rounded,
            text: appointment.timeLabel,
          ),

          const SizedBox(height: 10),

          HomeAppointmentDetailLine(
            icon: Icons.calendar_month_rounded,
            text: appointment.dateLabel,
          ),

          if (!_isFinal) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: HomeAppointmentActionButton(
                    label: 'مكتمل',
                    icon: Icons.done_all_rounded,
                    color: const Color(0xFF4A6FA8),
                    onTap: onMarkCompleted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: HomeAppointmentActionButton(
                    label: 'إلغاء',
                    icon: Icons.close_rounded,
                    color: const Color(0xFFC9544A),
                    onTap: onCancel,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class HomeAppointmentDetailLine extends StatelessWidget {
  const HomeAppointmentDetailLine({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Icon(icon, color: const Color(0xFF6B4F3E), size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeAppointmentStatusBadge extends StatelessWidget {
  const HomeAppointmentStatusBadge({super.key, required this.status});

  final String status;

  String get label {
    switch (status) {
      case 'قادم':
        return 'محجوز';
      case 'مؤكد':
        return 'مؤكد';
      case 'مكتمل':
      case 'مكتملة':
        return 'منجز';
      case 'ملغي':
      case 'ملغية':
        return 'ملغي';
      case 'لم يحضر':
        return 'لم يحضر';
      case 'جاري':
        return 'جاري';
      default:
        return status;
    }
  }

  Color get textColor {
    switch (status) {
      case 'مؤكد':
        return const Color(0xFF1E4A36);
      case 'ملغي':
      case 'ملغية':
        return const Color(0xFF7A2E2A);
      case 'لم يحضر':
        return const Color(0xFF6B3D28);
      case 'مكتمل':
      case 'مكتملة':
        return const Color(0xFF2C4F78);
      default:
        return const Color(0xFF4C3D66);
    }
  }

  List<Color> get gradientColors {
    switch (status) {
      case 'مؤكد':
        return const [Color(0xFFE8F2EC), Color(0xFFD4E8DC)];
      case 'ملغي':
      case 'ملغية':
        return const [Color(0xFFF8E9E8), Color(0xFFEFD5D3)];
      case 'لم يحضر':
        return const [Color(0xFFFAF3EB), Color(0xFFF0E0D0)];
      case 'مكتمل':
      case 'مكتملة':
        return const [Color(0xFFE8EEF6), Color(0xFFD6E2F0)];
      default:
        return const [Color(0xFFF2EEF8), Color(0xFFE6DFF0)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: textColor.withValues(alpha: 0.22)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class HomeAppointmentActionButton extends StatelessWidget {
  const HomeAppointmentActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
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
