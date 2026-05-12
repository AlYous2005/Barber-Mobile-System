import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class NotificationsActionsBar extends StatelessWidget {
  const NotificationsActionsBar({
    super.key,
    required this.unreadCount,
    required this.onMarkAllAsRead,
  });

  final int unreadCount;
  final VoidCallback onMarkAllAsRead;

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hasUnread
                  ? const Color(0xFFC47A3D).withValues(alpha: 0.12)
                  : AppThemeColors.softCard(context),
              borderRadius: BorderRadius.circular(14),
              border: hasUnread
                  ? null
                  : Border.all(color: AppThemeColors.border(context)),
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: hasUnread
                  ? const Color(0xFFC47A3D)
                  : AppThemeColors.textMuted(context),
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              unreadCount == 0
                  ? 'لا يوجد إشعارات تحتاج متابعة'
                  : 'عندك $unreadCount إشعارات غير مقروءة',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: hasUnread
                ? const Color(0xFFC47A3D)
                : AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onMarkAllAsRead,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: hasUnread
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppThemeColors.border(context),
                        ),
                      ),
                child: Text(
                  'قراءة الكل',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: hasUnread
                        ? Colors.white
                        : AppThemeColors.textMuted(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
