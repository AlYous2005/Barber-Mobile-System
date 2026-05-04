import 'package:flutter/material.dart';

import '../../../models/mock_notification.dart';

class CustomerNotificationsDropdown extends StatelessWidget {
  const CustomerNotificationsDropdown({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final notifications = mockCustomerNotifications;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEADBCD)),
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
                  color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFC47A3D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'إشعاراتي',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (notifications.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'لا توجد إشعارات حالياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
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
        color: isRead ? Colors.white : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead ? const Color(0xFFE5E7EB) : const Color(0xFFF3D4A7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF3F4F6) : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
              color: isRead ? const Color(0xFF6B7280) : const Color(0xFFC47A3D),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              readableMessage,
              style: TextStyle(
                color: const Color(0xFF111827),
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