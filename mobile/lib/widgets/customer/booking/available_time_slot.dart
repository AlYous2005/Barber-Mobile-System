import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import '../home/customer_theme.dart';

class AvailableTimeSlot extends StatelessWidget {
  const AvailableTimeSlot({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? CustomerTheme.accentOrange.withValues(alpha: 0.28)
                : AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? CustomerTheme.accentOrange
                  : AppThemeColors.border(context),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? AppThemeColors.textPrimary(context)
                  : AppThemeColors.textSecondary(context),
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
