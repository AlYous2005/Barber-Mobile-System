import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import 'settings_shared_widgets.dart';

class NotificationsSettingsCard extends StatelessWidget {
  const NotificationsSettingsCard({
    super.key,
    required this.notificationsEnabled,
    required this.onToggle,
  });

  final bool notificationsEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = notificationsEnabled
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return SettingsCardShell(
      child: Column(
        children: [
          Row(
            children: [
              SettingsIconBox(
                icon: Icons.notifications_active_rounded,
                color: const Color(0xFFC47A3D),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إشعارات التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'فعّل أو أوقف إشعارات الحجوزات الجديدة وتحديثات المواعيد.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: StatusPill(
                  label: notificationsEnabled
                      ? 'الإشعارات مفعلة'
                      : 'الإشعارات متوقفة',
                  color: statusColor,
                ),
              ),

              const SizedBox(width: 10),

              Switch(
                value: notificationsEnabled,
                activeThumbColor: const Color(0xFF16A34A),
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
