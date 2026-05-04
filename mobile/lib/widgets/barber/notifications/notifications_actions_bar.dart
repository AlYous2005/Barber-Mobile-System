import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEADBCD),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: Color(0xFFC47A3D),
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              unreadCount == 0
                  ? 'لا يوجد إشعارات تحتاج متابعة'
                  : 'عندك $unreadCount إشعارات غير مقروءة',
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A2018),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (unreadCount > 0)
            Material(
              color: const Color(0xFFC47A3D),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onMarkAllAsRead,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: const Text(
                    'قراءة الكل',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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