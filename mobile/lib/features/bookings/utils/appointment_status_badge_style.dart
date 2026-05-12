import 'package:flutter/material.dart';

import 'appointment_status_utils.dart';

/// Shared icon + capsule styling for appointment status badges.
class AppointmentStatusBadgeStyle {
  const AppointmentStatusBadgeStyle({
    required this.icon,
    required this.gradientColors,
    required this.borderColor,
    required this.foregroundColor,
    required this.shortLabel,
    required this.visualStatusKey,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color foregroundColor;

  /// Shown beside the icon (display label).
  final String shortLabel;

  /// Key for [AnimatedSwitcher] when status changes affect visuals.
  final String visualStatusKey;

  factory AppointmentStatusBadgeStyle.fromArabicStatus(String status) {
    final String label = AppointmentStatusUtils.displayLabel(status);

    if (AppointmentStatusUtils.isConfirmed(status) ||
        AppointmentStatusUtils.isCurrent(status)) {
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'confirmed',
        icon: Icons.verified_rounded,
        shortLabel: label,
        foregroundColor: const Color(0xFF1E4A36),
        gradientColors: const [Color(0xFFE8F2EC), Color(0xFFD4E8DC)],
        borderColor: const Color(0xFF1E4A36),
      );
    }
    if (AppointmentStatusUtils.isCancelled(status)) {
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'cancelled',
        icon: Icons.cancel_rounded,
        shortLabel: label,
        foregroundColor: const Color(0xFF7A2E2A),
        gradientColors: const [Color(0xFFF8E9E8), Color(0xFFEFD5D3)],
        borderColor: const Color(0xFF7A2E2A),
      );
    }
    if (AppointmentStatusUtils.isNoShow(status)) {
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'noshow',
        icon: Icons.person_off_rounded,
        shortLabel: label,
        foregroundColor: const Color(0xFF6B3D28),
        gradientColors: const [Color(0xFFFAF3EB), Color(0xFFF0E0D0)],
        borderColor: const Color(0xFF6B3D28),
      );
    }
    if (AppointmentStatusUtils.isCompleted(status)) {
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'completed',
        icon: Icons.check_circle_rounded,
        shortLabel: label,
        foregroundColor: const Color(0xFF2C4F78),
        gradientColors: const [Color(0xFFE8EEF6), Color(0xFFD6E2F0)],
        borderColor: const Color(0xFF2C4F78),
      );
    }

    final bool urgent = AppointmentStatusUtils.isPending(status);

    return AppointmentStatusBadgeStyle(
      visualStatusKey: 'default',
      icon: urgent ? Icons.hourglass_top_rounded : Icons.info_rounded,
      shortLabel: label,
      foregroundColor: const Color(0xFF4C3D66),
      gradientColors: const [Color(0xFFF2EEF8), Color(0xFFE6DFF0)],
      borderColor: const Color(0xFF4C3D66),
    );
  }
}

/// Match legacy customer card hues where useful.
AppointmentStatusBadgeStyle appointmentStatusBadgeStyleForCustomerCard(
  String rawStatus,
) {
  switch (rawStatus) {
    case 'معلق':
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'pending',
        icon: Icons.hourglass_top_rounded,
        shortLabel: AppointmentStatusUtils.displayLabel(rawStatus),
        foregroundColor: const Color(0xFFF59E0B),
        gradientColors: const [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
        borderColor: const Color(0xFFF59E0B),
      );

    case 'قادم':
    case 'تم التأكيد':
    case 'مؤكد':
    case 'مؤكدة':
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'confirmed',
        icon: Icons.verified_rounded,
        shortLabel:
            rawStatus == 'قادم' ? 'محجوز' : AppointmentStatusUtils.displayLabel(rawStatus),
        foregroundColor: const Color(0xFF2563EB),
        gradientColors: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
        borderColor: const Color(0xFF2563EB),
      );

    case 'مكتمل':
    case 'مكتملة':
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'completed',
        icon: Icons.check_circle_rounded,
        shortLabel: AppointmentStatusUtils.displayLabel(rawStatus),
        foregroundColor: const Color(0xFF16A34A),
        gradientColors: const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
        borderColor: const Color(0xFF16A34A),
      );

    case 'ملغي':
    case 'ملغية':
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'cancelled',
        icon: Icons.cancel_rounded,
        shortLabel: AppointmentStatusUtils.displayLabel(rawStatus),
        foregroundColor: const Color(0xFFEF4444),
        gradientColors: const [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
        borderColor: const Color(0xFFEF4444),
      );

    case 'لم يحضر':
      return AppointmentStatusBadgeStyle(
        visualStatusKey: 'noshow',
        icon: Icons.person_off_rounded,
        shortLabel: AppointmentStatusUtils.displayLabel(rawStatus),
        foregroundColor: const Color(0xFF6B3D28),
        gradientColors: const [Color(0xFFFAF3EB), Color(0xFFF0E0D0)],
        borderColor: const Color(0xFF6B3D28),
      );

    default:
      return AppointmentStatusBadgeStyle.fromArabicStatus(rawStatus);
  }
}
