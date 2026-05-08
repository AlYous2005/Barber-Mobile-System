import 'package:flutter/material.dart';

import '../../../models/mock_appointment.dart';
import '../../../utils/app_theme_colors.dart';
import '../../../utils/appointment_status_utils.dart';
import '../../../utils/booking_formatters.dart';
import '../shared/user_avatar_box.dart';

class HomeAppointmentCard extends StatelessWidget {
  const HomeAppointmentCard({
    super.key,
    required this.appointment,
    required this.onConfirm,
    required this.onMarkCompleted,
    required this.onNoShow,
    required this.onCancel,
  });

  final MockAppointment appointment;
  final VoidCallback onConfirm;
  final VoidCallback onMarkCompleted;
  final VoidCallback onNoShow;
  final VoidCallback onCancel;

  bool get _isPending {
    return AppointmentStatusUtils.isPending(appointment.status);
  }

  bool get _isConfirmed {
    return AppointmentStatusUtils.isConfirmed(appointment.status);
  }

  bool get _isFinal {
    return AppointmentStatusUtils.isFinal(appointment.status);
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
          Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: appointment.createdAt != null
                      ? Text(
                          formatAppointmentBookedAtLine(appointment.createdAt!),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppThemeColors.textMuted(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              HomeAppointmentStatusBadge(status: appointment.status),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              UserAvatarBox(
                displayName: appointment.displayCustomerName,
                imageUrl: appointment.customerAvatarUrl,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appointment.displayCustomerName,
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
            text: appointment.displayTimeRange,
          ),

          const SizedBox(height: 10),

          HomeAppointmentDetailLine(
            icon: Icons.calendar_month_rounded,
            text: appointment.dateLabel,
          ),

          if (!_isFinal) ...[const SizedBox(height: 16), _buildActions()],
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (_isPending) {
      return Row(
        children: [
          Expanded(
            child: HomeAppointmentActionButton(
              label: 'تأكيد',
              icon: Icons.check_rounded,
              color: const Color(0xFF3D7A5C),
              onTap: onConfirm,
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
      );
    }

    if (_isConfirmed) {
      return Column(
        children: [
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
                  label: 'عدم حضور',
                  icon: Icons.person_off_rounded,
                  color: const Color(0xFFC2783A),
                  onTap: onNoShow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          HomeAppointmentActionButton(
            label: 'إلغاء',
            icon: Icons.close_rounded,
            color: const Color(0xFFC9544A),
            onTap: onCancel,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: HomeAppointmentActionButton(
            label: 'إلغاء',
            icon: Icons.close_rounded,
            color: const Color(0xFFC9544A),
            onTap: onCancel,
          ),
        ),
      ],
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
    return AppointmentStatusUtils.displayLabel(status);
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
