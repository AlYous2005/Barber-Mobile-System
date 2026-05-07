import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.barberName,
    required this.hasSelectedImage,
    required this.avatarUrl,
    required this.isUploadingImage,
    required this.onImageTap,
  });

  final String barberName;
  final bool hasSelectedImage;
  final String? avatarUrl;
  final bool isUploadingImage;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppThemeColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: dark ? AppThemeColors.elevatedCard(context) : null,
        gradient: dark
            ? null
            : const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFFFFBF2), Color(0xFFFFF7E6), Colors.white],
              ),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12C47A3D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: isUploadingImage ? null : onImageTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFFC47A3D), Color(0xFFF6D38B)],
                    ),
                    boxShadow: dark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.38),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(
                                0xFF5C3D24,
                              ).withValues(alpha: 0.20),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ClipOval(
                    child: _ProfileAvatarContent(
                      avatarUrl: avatarUrl,
                      hasSelectedImage: hasSelectedImage,
                      isUploadingImage: isUploadingImage,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 5,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF111827),
                      border: Border.all(
                        color: AppThemeColors.card(context),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      isUploadingImage
                          ? Icons.hourglass_empty_rounded
                          : Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.20),
              ),
            ),
            child: const Text(
              'الملف الشخصي المهني',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF8A4E2E),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            barberName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isUploadingImage
                ? 'جاري تحديث صورة الحلاق...'
                : 'اضغط على الصورة لتغيير صورة الحلاق',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarContent extends StatelessWidget {
  const _ProfileAvatarContent({
    required this.avatarUrl,
    required this.hasSelectedImage,
    required this.isUploadingImage,
  });

  final String? avatarUrl;
  final bool hasSelectedImage;
  final bool isUploadingImage;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl?.trim();

    if (isUploadingImage) {
      return Container(
        color: AppThemeColors.softCard(context),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return _AvatarFallback(hasSelectedImage: hasSelectedImage);
        },
      );
    }

    return _AvatarFallback(hasSelectedImage: hasSelectedImage);
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.hasSelectedImage});

  final bool hasSelectedImage;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppThemeColors.softCard(context),
      child: Icon(
        hasSelectedImage ? Icons.image_rounded : Icons.content_cut_rounded,
        size: 38,
        color: const Color(0xFFC47A3D),
      ),
    );
  }
}
