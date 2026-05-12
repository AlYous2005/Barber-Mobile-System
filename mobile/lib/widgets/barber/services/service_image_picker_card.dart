import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class ServiceImagePickerCard extends StatelessWidget {
  const ServiceImagePickerCard({
    super.key,
    required this.imageUrl,
    required this.isUploading,
    required this.onPickImage,
    required this.onClearImage,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    final String? cleanImageUrl = _cleanText(imageUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'صورة الخدمة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppThemeColors.textSecondary(context),
          ),
        ),

        const SizedBox(height: 9),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: cleanImageUrl == null
                    ? _EmptyImagePreview(isUploading: isUploading)
                    : _ImagePreview(
                        imageUrl: cleanImageUrl,
                        isUploading: isUploading,
                      ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ImageActionButton(
                      label: cleanImageUrl == null
                          ? 'رفع صورة'
                          : 'تغيير الصورة',
                      icon: Icons.image_rounded,
                      onTap: isUploading ? null : onPickImage,
                      primary: true,
                    ),
                  ),

                  if (cleanImageUrl != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ImageActionButton(
                        label: 'إزالة الصورة',
                        icon: Icons.close_rounded,
                        onTap: isUploading ? null : onClearImage,
                        primary: false,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'إذا لم تضف صورة، سيتم عرض الأيقونة المختارة بدلًا منها',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textMuted(context),
                  fontSize: 11.5,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _cleanText(String? value) {
    if (value == null) {
      return null;
    }

    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _EmptyImagePreview extends StatelessWidget {
  const _EmptyImagePreview({required this.isUploading});

  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty-service-image'),
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppThemeColors.border(context),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: isUploading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    color: AppThemeColors.textMuted(context),
                    size: 34,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم يتم اختيار صورة',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary(context),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl, required this.isUploading});

  final String imageUrl;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('selected-service-image'),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 130,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: AppThemeColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppThemeColors.border(context)),
                ),
                child: Icon(
                  Icons.broken_image_rounded,
                  color: AppThemeColors.textMuted(context),
                  size: 34,
                ),
              );
            },
          ),
        ),

        if (isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _ImageActionButton extends StatelessWidget {
  const _ImageActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color color = primary
        ? const Color(0xFFC47A3D)
        : AppThemeColors.textSecondary(context);

    return Material(
      color: primary
          ? const Color(0xFFC47A3D).withValues(alpha: 0.12)
          : AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primary
                  ? const Color(0xFFC47A3D).withValues(alpha: 0.28)
                  : AppThemeColors.border(context),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
