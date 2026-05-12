import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class UserAvatarBox extends StatelessWidget {
  const UserAvatarBox({
    super.key,
    required this.displayName,
    this.imageUrl,
    this.size = 42,
    this.borderRadius = 14,
  });

  final String displayName;
  final String? imageUrl;
  final double size;
  final double borderRadius;

  String get _fallbackLetter {
    final cleaned = displayName.trim();
    if (cleaned.isEmpty) return '؟';
    return cleaned.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final cleanedImageUrl = imageUrl?.trim();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanedImageUrl == null || cleanedImageUrl.isEmpty
          ? _FallbackAvatar(letter: _fallbackLetter)
          : Image.network(
              cleanedImageUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return _FallbackAvatar(letter: _fallbackLetter);
              },
            ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: TextStyle(
          color: AppThemeColors.textPrimary(context),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
