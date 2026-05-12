import 'package:flutter/material.dart';

import '../../../features/barber/profile/barber_profile.dart';
import '../../../general_utils/app_theme_colors.dart';

class DistributionSection extends StatelessWidget {
  const DistributionSection({super.key, required this.snapshot});

  final SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final int total = snapshot.distribution.fold(
      0,
      (sum, item) => sum + item.value,
    );

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
                Icons.bar_chart_rounded,
                color: Color(0xFF9A5A38),
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'توزيع الحالات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...snapshot.distribution.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DistributionBar(item: item, total: total),
            ),
          ),
        ],
      ),
    );
  }
}

class DistributionBar extends StatelessWidget {
  const DistributionBar({super.key, required this.item, required this.total});

  final DistributionItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double ratio = total == 0 ? 0 : item.value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              '${item.value}',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: item.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            color: AppThemeColors.softCard(context),
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
