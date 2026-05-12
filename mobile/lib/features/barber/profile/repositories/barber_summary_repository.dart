import 'package:flutter/material.dart';

import '../models/summary_models.dart';
import '../../../../services/supabase_config.dart';

class BarberSummaryRepository {
  const BarberSummaryRepository();

  Future<SummarySnapshot> getSummarySnapshot({
    required String barberId,
    required String filterLabel,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final appointmentRows = await SupabaseConfig.client
        .from('appointments')
        .select(
          'id, appointment_date, start_time, status, total_price, customer_id',
        )
        .eq('barber_id', barberId)
        .gte('appointment_date', _dateForDatabase(startDate))
        .lte('appointment_date', _dateForDatabase(endDate));

    final totalAppointments = appointmentRows.length;

    final completedAppointments = appointmentRows.where((row) {
      return row['status']?.toString() == 'completed';
    }).length;

    final cancelledAppointments = appointmentRows.where((row) {
      final status = row['status']?.toString();
      return status == 'cancelled' || status == 'no_show';
    }).length;

    final pendingAppointments = appointmentRows.where((row) {
      final status = row['status']?.toString();
      return status == 'pending' || status == 'confirmed';
    }).length;

    final revenue = appointmentRows.fold<double>(0, (sum, row) {
      final status = row['status']?.toString();

      if (status != 'completed') {
        return sum;
      }

      return sum + _parseDouble(row['total_price']);
    });

    final activeCustomers = appointmentRows
        .map((row) => row['customer_id']?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .length;

    final bestService = await _loadBestServiceName(
      appointmentRows: appointmentRows,
    );

    final topHour = _calculateTopHour(appointmentRows);

    final averageTicket = completedAppointments == 0
        ? '0 ₪'
        : '${(revenue / completedAppointments).round()} ₪';

    final completionRate = totalAppointments == 0
        ? '0%'
        : '${((completedAppointments / totalAppointments) * 100).round()}%';

    return SummarySnapshot(
      filterLabel: filterLabel,
      totalAppointments: totalAppointments,
      completedAppointments: completedAppointments,
      cancelledAppointments: cancelledAppointments,
      pendingAppointments: pendingAppointments,
      revenue: revenue.round(),
      completionRate: completionRate,
      bestService: bestService,
      averageTicket: averageTicket,
      activeCustomers: activeCustomers,
      topHour: topHour,
      distribution: [
        DistributionItem(
          label: 'مكتملة',
          value: completedAppointments,
          color: const Color(0xFF2E8B57),
        ),
        DistributionItem(
          label: 'ملغية',
          value: cancelledAppointments,
          color: const Color(0xFFD9534F),
        ),
        DistributionItem(
          label: 'معلقة',
          value: pendingAppointments,
          color: const Color(0xFFC68A2D),
        ),
      ],
    );
  }

  Future<String> _loadBestServiceName({
    required List<dynamic> appointmentRows,
  }) async {
    final appointmentIds = appointmentRows
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (appointmentIds.isEmpty) {
      return 'لا يوجد';
    }

    final serviceRows = await SupabaseConfig.client
        .from('appointment_services')
        .select('service_name_snapshot')
        .inFilter('appointment_id', appointmentIds);

    if (serviceRows.isEmpty) {
      return 'لا يوجد';
    }

    final Map<String, int> counts = {};

    for (final row in serviceRows) {
      final serviceName = row['service_name_snapshot']?.toString().trim();

      if (serviceName == null || serviceName.isEmpty) {
        continue;
      }

      counts[serviceName] = (counts[serviceName] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return 'لا يوجد';
    }

    final sorted = counts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    return sorted.first.key;
  }

  String _calculateTopHour(List<dynamic> appointmentRows) {
    if (appointmentRows.isEmpty) {
      return 'لا يوجد';
    }

    final Map<int, int> hourCounts = {};

    for (final row in appointmentRows) {
      final startTime = row['start_time']?.toString();

      if (startTime == null || startTime.isEmpty) {
        continue;
      }

      final hour = int.tryParse(startTime.split(':').first);

      if (hour == null) {
        continue;
      }

      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    if (hourCounts.isEmpty) {
      return 'لا يوجد';
    }

    final sorted = hourCounts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    final topHour = sorted.first.key;

    return _formatHour(topHour);
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'صباحًا' : 'مساءً';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:00 $period';
  }

  String _dateForDatabase(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  double _parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
