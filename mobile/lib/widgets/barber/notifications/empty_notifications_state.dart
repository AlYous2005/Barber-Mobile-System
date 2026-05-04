import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: AppThemeColors.textMuted(context),
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'لا توجد إشعارات في هذا القسم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
