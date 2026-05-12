import 'package:flutter/material.dart';

import '../../../features/notifications/models/barber_notification_ui_model.dart';
import '../../../general_utils/app_theme_colors.dart';

class NotificationLuxuryCard extends StatelessWidget {
  const NotificationLuxuryCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final UiNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final NotificationVisual visual = _visualFor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: notification.isRead
            ? AppThemeColors.card(context)
            : visual.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: notification.isRead
                    ? AppThemeColors.border(context)
                    : visual.color.withValues(alpha: 0.24),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: visual.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: visual.color.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Icon(visual.icon, color: visual.color, size: 23),
                    ),

                    if (!notification.isRead)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEF4444),
                            border: Border.all(
                              color: AppThemeColors.card(context),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NotificationBadge(
                            label: visual.label,
                            color: visual.color,
                          ),

                          const Spacer(),

                          Text(
                            notification.timeLabel,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.textMuted(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: notification.isRead
                              ? FontWeight.w700
                              : FontWeight.w900,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),

                      const SizedBox(height: 11),

                      Row(
                        children: [
                          Text(
                            visual.actionText,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: visual.color,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: visual.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static NotificationVisual _visualFor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const NotificationVisual(
          label: 'حجز',
          actionText: 'فتح المواعيد',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFF2563EB),
        );

      case NotificationType.customerAccessRequest:
        return const NotificationVisual(
          label: 'طلبات حجز',
          actionText: 'فتح الطلبات',
          icon: Icons.person_add_alt_1_rounded,
          color: Color(0xFFC47A3D),
        );

      case NotificationType.customerAccessResponse:
        return const NotificationVisual(
          label: 'رد الطلب',
          actionText: 'عرض الطلب',
          icon: Icons.verified_user_rounded,
          color: Color(0xFF16A34A),
        );

      case NotificationType.service:
        return const NotificationVisual(
          label: 'خدمة',
          actionText: 'فتح الخدمات',
          icon: Icons.content_cut_rounded,
          color: Color(0xFFC47A3D),
        );

      case NotificationType.workingHours:
        return const NotificationVisual(
          label: 'ساعات العمل',
          actionText: 'فتح ساعات العمل',
          icon: Icons.schedule_rounded,
          color: Color(0xFF16A34A),
        );

      case NotificationType.availability:
        return const NotificationVisual(
          label: 'توفر',
          actionText: 'فتح التوفر والإغلاقات',
          icon: Icons.event_busy_rounded,
          color: Color(0xFF8B5CF6),
        );

      case NotificationType.summary:
        return const NotificationVisual(
          label: 'إنجاز',
          actionText: 'فتح الملخصات',
          icon: Icons.bar_chart_rounded,
          color: Color(0xFFF59E0B),
        );

      case NotificationType.system:
        return const NotificationVisual(
          label: 'نظام',
          actionText: 'عرض التفاصيل',
          icon: Icons.info_rounded,
          color: Color(0xFF64748B),
        );
    }
  }
}

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
