import 'package:flutter/material.dart';

class SummarySnapshot {
  const SummarySnapshot({
    required this.filterLabel,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.pendingAppointments,
    required this.revenue,
    required this.completionRate,
    required this.bestService,
    required this.averageTicket,
    required this.activeCustomers,
    required this.topHour,
    required this.distribution,
  });

  final String filterLabel;
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int pendingAppointments;
  final int revenue;
  final String completionRate;
  final String bestService;
  final String averageTicket;
  final int activeCustomers;
  final String topHour;
  final List<DistributionItem> distribution;
}

class DistributionItem {
  const DistributionItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class SummaryCardData {
  const SummaryCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
}

class InsightData {
  const InsightData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}
