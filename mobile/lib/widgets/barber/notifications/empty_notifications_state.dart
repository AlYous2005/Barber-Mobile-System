import 'package:flutter/material.dart';

class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF9CA3AF),
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'لا توجد إشعارات في هذا القسم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}