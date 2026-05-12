import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import '../../../features/bookings/utils/booking_formatters.dart';

class ServicesLiveCounter extends StatelessWidget {
  const ServicesLiveCounter({
    super.key,
    required this.totalPrice,
    required this.totalDuration,
    required this.selectedCount,
  });

  final int totalPrice;
  final int totalDuration;

  /// نتركه موجود حتى لا نكسر الاستدعاءات الحالية من الشاشة،
  /// لكن لن نعرضه داخل الكرت الآن.
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool compact = screenSize.width < 380 || screenSize.height < 740;
    final bool dark = AppThemeColors.isDark(context);

    final Color cardColor = dark
        ? const Color(0xFF241711)
        : const Color(0xFFFFFCF8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(compact ? 18 : 20),
        border: Border.all(
          color: const Color(0xFFC47A3D).withValues(alpha: 0.42),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _CompactMetricItem(
              icon: Icons.payments_rounded,
              label: 'حسابك الكلي',
              value: '$totalPrice شيكل',
              color: const Color(0xFF16A34A),
              compact: compact,
            ),
          ),

          Container(
            width: 1,
            height: compact ? 34 : 40,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFFC47A3D).withValues(alpha: 0.24),
          ),

          Expanded(
            child: _CompactMetricItem(
              icon: Icons.access_time_rounded,
              label: 'المدة',
              value: formatBookingDuration(totalDuration),
              color: const Color(0xFFC47A3D),
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetricItem extends StatelessWidget {
  const _CompactMetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: compact ? 30 : 34,
          height: compact ? 30 : 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: compact ? 16 : 18),
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: compact ? 10.5 : 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  value,
                  key: ValueKey('$label-$value'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: compact ? 12.5 : 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
