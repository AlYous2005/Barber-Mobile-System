import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class CustomerHomeTopBar extends StatelessWidget {
  const CustomerHomeTopBar({
    super.key,
    required this.displayName,
    required this.unreadCount,
    required this.onProfileTap,
    required this.onNotificationsTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    required this.avatarUrl,
  });

  final String displayName;
  final int unreadCount;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppThemeColors.card(context),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppThemeColors.border(context)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CustomerProfileAvatar(
                    displayName: displayName,
                    avatarUrl: avatarUrl,
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 112,
                    child: _SmartMarqueeText(text: displayName),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderActionButton(
                    icon: Icons.logout_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: onLogoutTap,
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    icon: Icons.settings_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: onSettingsTap,
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    icon: Icons.notifications_active_rounded,
                    color: const Color(0xFFC47A3D),
                    onTap: onNotificationsTap,
                    badgeCount: unreadCount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerProfileAvatar extends StatelessWidget {
  const _CustomerProfileAvatar({required this.displayName, this.avatarUrl});

  final String displayName;
  final String? avatarUrl;

  String get _fallbackLetter {
    final cleaned = displayName.trim();
    if (cleaned.isEmpty) return '؟';
    return cleaned.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final cleanedAvatarUrl = avatarUrl?.trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
            ),
            border: Border.all(color: const Color(0xFFE7B679), width: 2.6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22C47A3D),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: cleanedAvatarUrl == null || cleanedAvatarUrl.isEmpty
              ? Center(
                  child: Text(
                    _fallbackLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              : Image.network(
                  cleanedAvatarUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        _fallbackLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          left: 1,
          bottom: 1,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E),
              border: Border.all(color: AppThemeColors.card(context), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x7722C55E),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppThemeColors.card(context),
                  width: 1.5,
                ),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SmartMarqueeText extends StatefulWidget {
  const _SmartMarqueeText({required this.text});

  final String text;

  @override
  State<_SmartMarqueeText> createState() => _SmartMarqueeTextState();
}

class _SmartMarqueeTextState extends State<_SmartMarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  TextStyle _textStyle(BuildContext context) {
    return TextStyle(
      color: AppThemeColors.textPrimary(context),
      fontSize: 16,
      fontWeight: FontWeight.w900,
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isOverflowing({
    required BuildContext context,
    required String text,
    required double maxWidth,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: _textStyle(context)),
      maxLines: 1,
      textDirection: TextDirection.rtl,
    )..layout();

    return painter.width > maxWidth;
  }

  double _textWidth(BuildContext context, String text) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: _textStyle(context)),
      maxLines: 1,
      textDirection: TextDirection.rtl,
    )..layout();

    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool shouldAnimate = _isOverflowing(
          context: context,
          text: widget.text,
          maxWidth: constraints.maxWidth,
        );

        if (!shouldAnimate) {
          return Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: _textStyle(context),
          );
        }

        final double textWidth = _textWidth(context, widget.text);
        final double travelDistance = textWidth - constraints.maxWidth + 34;

        return ClipRect(
          child: SizedBox(
            height: 24,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double progress = _controller.value;
                final double pauseStart = 0.10;
                final double pauseEnd = 0.90;

                double dx = 0;

                if (progress < pauseStart) {
                  dx = 0;
                } else if (progress > pauseEnd) {
                  dx = 0;
                } else {
                  final double moveProgress =
                      (progress - pauseStart) / (pauseEnd - pauseStart);

                  dx = -travelDistance * moveProgress;
                }

                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: textWidth + 40,
                      child: Text(
                        widget.text,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.right,
                        style: _textStyle(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
