import 'package:flutter/material.dart';

class NotificationsIntroCard extends StatelessWidget {
  const NotificationsIntroCard({
    super.key,
    required this.unreadCount,
  });

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6E3F2F),
            Color(0xFF9B5A3D),
            Color(0xFFC37A49),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NotificationsCenterPill(),
          const SizedBox(height: 14),
          const Text(
            'الإشعارات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'تابع الحجوزات والتحديثات المهمة لحظة بلحظة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: Text(
              unreadCount == 0
                  ? 'كل الإشعارات مقروءة'
                  : '$unreadCount إشعارات غير مقروءة',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsCenterPill extends StatelessWidget {
  const NotificationsCenterPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.notifications_active_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}