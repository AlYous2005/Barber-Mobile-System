import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import 'settings_shared_widgets.dart';

class SalonImageSettingsCard extends StatelessWidget {
  const SalonImageSettingsCard({
    super.key,
    required this.hasSalonImage,
    required this.salonImageUrl,
    required this.isUploadingSalonImage,
    required this.onAddOrChangeImage,
    required this.onRemoveImage,
  });

  final bool hasSalonImage;
  final String? salonImageUrl;
  final bool isUploadingSalonImage;
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
            GestureDetector(
              onTap: () => _showFullScreenImagePreview(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  color: const Color(0xFF17110D),
                  child: _SalonImagePreview(salonImageUrl: salonImageUrl),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'اضغط على الصورة لمعاينتها بشكل أكبر',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _SalonImageButton(
                  label: isUploadingSalonImage
                      ? 'جاري الرفع...'
                      : hasSalonImage
                      ? 'تعديل الصورة'
                      : 'إضافة صورة',
                  icon: hasSalonImage
                      ? Icons.edit_rounded
                      : Icons.add_photo_alternate_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: isUploadingSalonImage ? null : onAddOrChangeImage,
                ),
              ),
              if (hasSalonImage) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _SalonImageButton(
                    label: isUploadingSalonImage
                        ? 'جاري الحذف...'
                        : 'إزالة الصورة',
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: isUploadingSalonImage ? null : onRemoveImage,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showFullScreenImagePreview(BuildContext context) {
    if (salonImageUrl == null || salonImageUrl!.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF17110D),
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'معاينة صورة الصالون',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF17110D),
                        alignment: Alignment.center,
                        child: Image.network(
                          salonImageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const _SalonImageFallback();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SalonImagePreview extends StatelessWidget {
  const _SalonImagePreview({required this.salonImageUrl});

  final String? salonImageUrl;

  @override
  Widget build(BuildContext context) {
    if (salonImageUrl == null || salonImageUrl!.isEmpty) {
      return const _SalonImageFallback();
    }

    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFF17110D),
      alignment: Alignment.center,
      child: Image.network(
        salonImageUrl!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const _SalonImageFallback();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _SalonImageFallback extends StatelessWidget {
  const _SalonImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2A2018), Color(0xFF6E3F2F), Color(0xFFC37A49)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_rounded, color: Colors.white, size: 36),
            SizedBox(height: 10),
            Text(
              'تعذر عرض صورة الصالون',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Material(
      color: isDisabled ? color.withValues(alpha: 0.55) : color,
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
