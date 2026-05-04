import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import 'customer_settings_shared_widgets.dart';

class CustomerNotificationsSettingsCard extends StatelessWidget {
  const CustomerNotificationsSettingsCard({
    super.key,
    required this.notificationsEnabled,
    required this.onChanged,
  });

  final bool notificationsEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = notificationsEnabled
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return CustomerSettingsCardShell(
      child: Column(
        children: [
          Row(
            children: [
              const CustomerSettingsIconBox(
                icon: Icons.notifications_active_rounded,
                color: Color(0xFFC47A3D),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إشعارات المواعيد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'نستخدمها لتذكيرك قبل موعدك بـ 15 دقيقة وتنبيهك عند تأكيد أو تغيير حالة الحجز.',
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
                child: CustomerSettingsStatusPill(
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
                onChanged: onChanged,
              ),
            ],
          ),

          const SizedBox(height: 12),

          const PermissionHintBox(),
        ],
      ),
    );
  }
}

class PermissionHintBox extends StatelessWidget {
  const PermissionHintBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFC47A3D), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'قد يطلب الهاتف إذنًا إضافيًا لتفعيل الإشعارات الخارجية. بدون هذا الإذن لن يصلك تنبيه خارج التطبيق.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
