import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class AvailabilitySheetHandle extends StatelessWidget {
  const AvailabilitySheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: AppThemeColors.border(context),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class AvailabilitySheetHeader extends StatelessWidget {
  const AvailabilitySheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.18),
            ),
          ),
          child: Icon(icon, color: const Color(0xFFC47A3D), size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppThemeColors.softCard(context),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onClose,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.close_rounded,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
