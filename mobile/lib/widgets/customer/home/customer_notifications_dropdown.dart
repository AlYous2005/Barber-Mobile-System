import 'package:flutter/material.dart';

import '../../../models/mock_notification.dart';
import '../../../utils/app_theme_colors.dart';

class CustomerNotificationsDropdown extends StatelessWidget {
  const CustomerNotificationsDropdown({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final notifications = mockCustomerNotifications;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppThemeColors.brandBrown(
                    context,
                  ).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: AppThemeColors.brandBrown(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'إشعاراتي',
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppThemeColors.textSecondary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (notifications.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Text(
                'لا توجد إشعارات حالياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            ...notifications
                .take(4)
                .map(
                  (item) => _CustomerNotificationMiniCard(
                    message: item.message,
                    isRead: item.isRead,
                  ),
                ),
        ],
      ),
    );
  }
}

class _CustomerNotificationMiniCard extends StatelessWidget {
  const _CustomerNotificationMiniCard({
    required this.message,
    required this.isRead,
  });

  final String message;
  final bool isRead;

  String get readableMessage {
    if (message.contains('حجز')) {
      return 'تم تحديث حالة أحد حجوزاتك. يمكنك مراجعة تفاصيل الموعد من قسم مواعيدي.';
    }

    if (message.contains('تقييم')) {
      return 'يمكنك الآن تقييم الحلاق بعد اكتمال موعدك.';
    }

    if (message.contains('تأكيد')) {
      return 'تم تأكيد موعدك من قبل الحلاق.';
    }

    if (message.contains('إلغاء') || message.contains('ملغي')) {
      return 'تم إلغاء أحد مواعيدك. راجع قسم مواعيدي لمعرفة التفاصيل.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isRead
            ? AppThemeColors.softCard(context)
            : AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead
              ? AppThemeColors.border(context)
              : AppThemeColors.brandBrown(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isRead
                  ? AppThemeColors.softCard(context)
                  : AppThemeColors.brandBrown(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
              color: isRead
                  ? AppThemeColors.textSecondary(context)
                  : AppThemeColors.brandBrown(context),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              readableMessage,
              style: TextStyle(
                color: AppThemeColors.textPrimary(context),
                fontSize: 13,
                height: 1.45,
                fontWeight: isRead ? FontWeight.w600 : FontWeight.w900,
              ),
            ),
          ),
          if (!isRead)
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }
}
