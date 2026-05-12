import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../../../general_utils/app_theme_colors.dart';

class CustomerNotificationsDropdown extends StatelessWidget {
  const CustomerNotificationsDropdown({
    super.key,
    required this.notifications,
    required this.onMarkAllAsRead,
    required this.onClose,
    this.onNearEndScroll,
    this.isLoadingMore = false,
    this.hasMoreNotifications = true,
  });

  final List<AppNotification> notifications;
  final VoidCallback onMarkAllAsRead;
  final VoidCallback onClose;

  /// Loads the next page when the inner list is scrolled near the bottom.
  final VoidCallback? onNearEndScroll;

  final bool isLoadingMore;
  final bool hasMoreNotifications;

  bool _scrollNearBottom(ScrollMetrics metrics) {
    if (!metrics.hasPixels || !metrics.hasViewportDimension) {
      return false;
    }
    const double threshold = 120;
    return metrics.pixels >= metrics.maxScrollExtent - threshold;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = notifications.any((item) => !item.isRead);

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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: hasUnread ? onMarkAllAsRead : null,
              icon: Icon(
                Icons.done_all_rounded,
                size: 18,
                color: hasUnread
                    ? AppThemeColors.brandBrown(context)
                    : AppThemeColors.textMuted(context),
              ),
              label: Text(
                'تعيين الكل كمقروء',
                style: TextStyle(
                  color: hasUnread
                      ? AppThemeColors.brandBrown(context)
                      : AppThemeColors.textMuted(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                backgroundColor: hasUnread
                    ? AppThemeColors.brandBrown(context).withValues(alpha: 0.08)
                    : AppThemeColors.softCard(context),
                side: BorderSide(
                  color: hasUnread
                      ? AppThemeColors.brandBrown(
                          context,
                        ).withValues(alpha: 0.5)
                      : AppThemeColors.border(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is! ScrollUpdateNotification &&
                      notification is! OverscrollNotification) {
                    return false;
                  }
                  if (!hasMoreNotifications ||
                      isLoadingMore ||
                      onNearEndScroll == null) {
                    return false;
                  }
                  if (_scrollNearBottom(notification.metrics)) {
                    onNearEndScroll!();
                  }
                  return false;
                },
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount:
                      notifications.length +
                      (isLoadingMore && hasMoreNotifications ? 1 : 0),
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 9),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= notifications.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      );
                    }
                    final AppNotification item = notifications[index];
                    return _CustomerNotificationMiniCard(
                      message: item.message,
                      isRead: item.isRead,
                    );
                  },
                ),
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

  String get displayMessage {
    final cleaned = message.trim();
    if (cleaned.isEmpty) {
      return 'لديك إشعار جديد';
    }
    return cleaned;
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
              displayMessage,
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
