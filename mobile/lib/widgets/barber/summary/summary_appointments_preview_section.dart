import 'package:flutter/material.dart';

import '../../../models/mock_appointment.dart';
import '../../../utils/app_theme_colors.dart';

class AppointmentsPreviewSection extends StatelessWidget {
  const AppointmentsPreviewSection({
    super.key,
    required this.filterLabel,
    required this.appointments,
  });

  final String filterLabel;
  final List<MockAppointment> appointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: Color(0xFF9A5A38),
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'أبرز المواعيد - $filterLabel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...appointments.map(
            (appointment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PreviewAppointmentCard(appointment: appointment),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewAppointmentCard extends StatelessWidget {
  const PreviewAppointmentCard({super.key, required this.appointment});

  final MockAppointment appointment;

  Color _statusColor(String status) {
    switch (status) {
      case 'مكتمل':
      case 'مكتملة':
        return const Color(0xFF22C55E);
      case 'ملغي':
      case 'ملغية':
        return const Color(0xFFEF4444);
      case 'قادم':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFC68A2D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(appointment.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppThemeColors.softCard(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppThemeColors.brandBrown(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.displayCustomerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.serviceName,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.dateLabel} • ${appointment.displayTimeRange}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              appointment.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
