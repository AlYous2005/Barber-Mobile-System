import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class WorkingHoursIntroCard extends StatelessWidget {
  const WorkingHoursIntroCard({super.key});

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
          colors: [Color(0xFF6E3F2F), Color(0xFF9B5A3D), Color(0xFFC37A49)],
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
          const WorkingHoursCenterPill(),

          const SizedBox(height: 14),

          Text(
            'ساعات العمل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
              height: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'حدد أيام وساعات دوام الحلاق لتظهر للزبائن بشكل صحيح',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkingHoursCenterPill extends StatelessWidget {
  const WorkingHoursCenterPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Working Hours Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.schedule_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
