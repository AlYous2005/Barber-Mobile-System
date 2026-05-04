import 'package:flutter/material.dart';

import '../../../models/summary_models.dart';

class InsightsSection extends StatelessWidget {
  const InsightsSection({super.key, required this.snapshot});

  final SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final insights = [
      InsightData(
        title: 'نسبة الإنجاز',
        value: snapshot.completionRate,
        subtitle: 'من إجمالي المواعيد',
        icon: Icons.insights_rounded,
        color: const Color(0xFF2563EB),
      ),
      InsightData(
        title: 'الخدمة الأفضل',
        value: snapshot.bestService,
        subtitle: 'الأكثر طلبًا',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFF16A34A),
      ),
      InsightData(
        title: 'متوسط التذكرة',
        value: snapshot.averageTicket,
        subtitle: 'لكل زبون',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFF59E0B),
      ),
      InsightData(
        title: 'الزبائن النشطون',
        value: '${snapshot.activeCustomers}',
        subtitle: 'في هذه الفترة',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      InsightData(
        title: 'الوقت الذهبي',
        value: snapshot.topHour,
        subtitle: 'أعلى ضغط',
        icon: Icons.schedule_rounded,
        color: const Color(0xFFEC4899),
      ),
      InsightData(
        title: 'المواعيد المعلقة',
        value: '${snapshot.pendingAppointments}',
        subtitle: 'بانتظار الإجراء',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFC68A2D),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEADBCD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_graph_rounded,
                color: Color(0xFF9A5A38),
                size: 21,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الرؤى والمؤشرات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...insights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InsightCard(data: item),
            ),
          ),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.data});

  final InsightData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              data.value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: data.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}