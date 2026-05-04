import 'package:flutter/material.dart';

import 'animated_crown_name.dart';
import 'header_icon_button.dart';
import 'notification_header_button.dart';

class BarberHeader extends StatelessWidget {
  const BarberHeader({
    super.key,
    required this.userName,
    required this.rating,
    required this.unreadNotifications,
    required this.onNotificationsTap,
    required this.onMenuTap,
  });

  final String userName;

  /// موجود حاليًا لأن الصفحة تمرره لنا.
  /// لاحقًا ممكن نستخدمه إذا رجعنا نعرض التقييم داخل الهيدر.
  final double rating;

  final int unreadNotifications;
  final VoidCallback onNotificationsTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final String displayName = userName.trim().isEmpty
        ? 'admin'
        : userName.trim();

        
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF2), Color(0xFFFFF7E6)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE8D8B8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x22C47A3D),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              HeaderIconButton(icon: Icons.menu_rounded, onTap: onMenuTap),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'الحلاق',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedCrownName(displayName: displayName),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              NotificationHeaderButton(
                unreadCount: unreadNotifications,
                onTap: onNotificationsTap,
              ),
            ],
          ),
        ),

        Positioned(
          left: 34,
          right: 34,
          bottom: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [
                  Color(0x00C47A3D),
                  Color(0xFFC47A3D),
                  Color(0x00C47A3D),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
