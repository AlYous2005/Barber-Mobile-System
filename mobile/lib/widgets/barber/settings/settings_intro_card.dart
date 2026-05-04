import 'package:flutter/material.dart';

class SettingsIntroCard extends StatelessWidget {
  const SettingsIntroCard({super.key});

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
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsCenterPill(),

          SizedBox(height: 14),

          Text(
            'الإعدادات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'تحكم بإشعارات التطبيق والمظهر العام بسهولة',
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

class SettingsCenterPill extends StatelessWidget {
  const SettingsCenterPill({super.key});

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
              'Settings Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.settings_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
