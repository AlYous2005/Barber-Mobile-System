import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class NotificationsFilterBar extends StatelessWidget {
  const NotificationsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.unreadCount,
    required this.appointmentsCount,
    required this.customerAccessRequestsCount,
    required this.systemCount,
    required this.onChanged,
  });

  final String selectedFilter;
  final int unreadCount;
  final int appointmentsCount;
  final int customerAccessRequestsCount;
  final int systemCount;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChipButton(
            label: 'الكل',
            value: 'all',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          FilterChipButton(
            label: 'غير مقروء',
            value: 'unread',
            badgeCount: unreadCount,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          FilterChipButton(
            label: 'الحجوزات',
            value: 'appointments',
            badgeCount: appointmentsCount,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          FilterChipButton(
            label: 'طلبات حجز',
            value: 'customer_access_requests',
            badgeCount: customerAccessRequestsCount,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          FilterChipButton(
            label: 'النظام',
            value: 'system',
            badgeCount: systemCount,
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.value,
    required this.selectedFilter,
    required this.onChanged,
    this.badgeCount = 0,
  });

  final String label;
  final String value;
  final String selectedFilter;
  final ValueChanged<String> onChanged;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedFilter;

    return Material(
      color: isSelected
          ? const Color(0xFF9A5A38)
          : AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF9A5A38)
                  : AppThemeColors.border(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? Colors.white
                      : AppThemeColors.textSecondary(context),
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.22)
                        : const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
