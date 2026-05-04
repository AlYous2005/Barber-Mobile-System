import 'package:flutter/material.dart';

import '../../../models/summary_models.dart';
import '../../../utils/app_theme_colors.dart';

class SummaryMiniStrip extends StatelessWidget {
  const SummaryMiniStrip({super.key, required this.snapshot});

  final SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppThemeColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: dark ? AppThemeColors.elevatedCard(context) : null,
        gradient: dark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFFDF7F1), Color(0xFFF7EEE6)],
              ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9A5A38), Color(0xFFB8774A)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص ${snapshot.filterLabel}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'إجمالي المواعيد: ${snapshot.totalAppointments} • الإيرادات: ${snapshot.revenue} ₪',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
