import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import 'settings_shared_widgets.dart';

class BarberAvatarSettingsCard extends StatelessWidget {
  const BarberAvatarSettingsCard({
    super.key,
    required this.hasBarberAvatar,
    required this.barberAvatarUrl,
    required this.isUploadingBarberAvatar,
    required this.onAddOrChangeAvatar,
    required this.onRemoveAvatar,
  });

  final bool hasBarberAvatar;
  final String? barberAvatarUrl;
  final bool isUploadingBarberAvatar;
  final VoidCallback onAddOrChangeAvatar;
  final VoidCallback onRemoveAvatar;

  @override
  Widget build(BuildContext context) {
    return SettingsCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SettingsIconBox(
                icon: Icons.account_circle_rounded,
                color: const Color(0xFFC47A3D),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصورة الشخصية للحلاق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'هذه الصورة ستظهر للزبائن عند اختيار الحلاق وأثناء الحجز.',
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
          const SizedBox(height: 16),
          Center(
            child: _AvatarPreview(
              avatarUrl: barberAvatarUrl,
              hasAvatar: hasBarberAvatar,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AvatarButton(
                  label: isUploadingBarberAvatar
                      ? 'جاري الرفع...'
                      : hasBarberAvatar
                      ? 'تعديل الصورة'
                      : 'إضافة صورة',
                  icon: hasBarberAvatar
                      ? Icons.edit_rounded
                      : Icons.add_photo_alternate_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: isUploadingBarberAvatar ? null : onAddOrChangeAvatar,
                ),
              ),
              if (hasBarberAvatar) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _AvatarButton(
                    label: isUploadingBarberAvatar ? 'جاري الحذف...' : 'إزالة',
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: isUploadingBarberAvatar ? null : onRemoveAvatar,
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

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.avatarUrl, required this.hasAvatar});

  final String? avatarUrl;
  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl?.trim();

    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC47A3D).withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl == null || imageUrl.isEmpty
            ? const _AvatarFallback()
            : Image.network(
                imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return const _AvatarFallback();
                },
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A1710),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;

    return Material(
      color: disabled ? color.withValues(alpha: 0.55) : color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
