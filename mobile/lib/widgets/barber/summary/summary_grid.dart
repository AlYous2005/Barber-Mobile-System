import 'package:flutter/material.dart';

import '../../../models/summary_models.dart';

class SummaryGrid extends StatelessWidget {
  const SummaryGrid({super.key, required this.snapshot});

  final SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = [
      SummaryCardData(
        title: 'إجمالي المواعيد',
        value: '${snapshot.totalAppointments}',
        subtitle: 'لكل ${snapshot.filterLabel}',
        color: const Color(0xFF3B82F6),
        icon: Icons.calendar_month_rounded,
      ),
      SummaryCardData(
        title: 'المواعيد المكتملة',
        value: '${snapshot.completedAppointments}',
        subtitle: 'مواعيد منجزة',
        color: const Color(0xFF22C55E),
        icon: Icons.check_circle_rounded,
      ),
      SummaryCardData(
        title: 'المواعيد الملغية',
        value: '${snapshot.cancelledAppointments}',
        subtitle: 'تم إلغاؤها',
        color: const Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
      ),
      SummaryCardData(
        title: 'الإيرادات',
        value: '${snapshot.revenue} ₪',
        subtitle: 'الدخل الإجمالي',
        color: const Color(0xFFF59E0B),
        icon: Icons.payments_rounded,
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return SummaryCard(data: cards[index]);
      },
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.data});

  final SummaryCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: data.color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.color, size: 22),
            ),
          ),
          const Spacer(),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2A2018),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: data.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}