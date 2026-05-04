import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import 'settings_shared_widgets.dart';

class SalonImageSettingsCard extends StatelessWidget {
  const SalonImageSettingsCard({
    super.key,
    required this.hasSalonImage,
    required this.onAddOrChangeImage,
    required this.onRemoveImage,
  });

  final bool hasSalonImage;
  final VoidCallback onAddOrChangeImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return SettingsCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SettingsIconBox(
                icon: Icons.storefront_rounded,
                color: const Color(0xFFC47A3D),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صورة الصالون',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'هذه الصورة ستظهر للعامة والزبائن عند قيامهم بالحجز. ينصح أن تبدو احترافية لتعكس صورة الصالون الجميلة.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (hasSalonImage) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF2A2018),
                    Color(0xFF6E3F2F),
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                    ),
                  ),

                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'معاينة صورة الصالون',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'سيتم عرض الصورة هنا بعد ربط الرفع الحقيقي',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _SalonImageButton(
                  label: hasSalonImage ? 'تعديل الصورة' : 'إضافة صورة',
                  icon: hasSalonImage
                      ? Icons.edit_rounded
                      : Icons.add_photo_alternate_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: onAddOrChangeImage,
                ),
              ),

              if (hasSalonImage) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _SalonImageButton(
                    label: 'إزالة الصورة',
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: onRemoveImage,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SalonImageButton extends StatelessWidget {
  const _SalonImageButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
