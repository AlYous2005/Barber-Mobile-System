import 'package:flutter/material.dart';

import 'profile_action_widgets.dart';

class ProfileImageOptionsSheet extends StatelessWidget {
  const ProfileImageOptionsSheet({
    super.key,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'تغيير صورة الحلاق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 14),

            SheetActionButton(
              label: 'اختيار صورة من الجهاز',
              icon: Icons.image_rounded,
              color: const Color(0xFFC47A3D),
              onTap: onPickImage,
            ),

            const SizedBox(height: 10),

            SheetActionButton(
              label: 'إزالة الصورة الحالية',
              icon: Icons.delete_outline_rounded,
              color: const Color(0xFFEF4444),
              onTap: onRemoveImage,
            ),
          ],
        ),
      ),
    );
  }
}