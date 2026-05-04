import 'package:flutter/material.dart';

class BarberHeader extends StatelessWidget {
  const BarberHeader({
    super.key,
    required this.userName,
    required this.rating,
    required this.unreadNotifications,
    required this.onNotificationsTap,
    required this.onMenuTap,
  });

  final String userName;

  /// موجود حاليًا لأن الصفحة تمرره لنا.
  /// لاحقًا ممكن نستخدمه إذا رجعنا نعرض التقييم داخل الهيدر.
  final double rating;

  final int unreadNotifications;
  final VoidCallback onNotificationsTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final String displayName = userName.trim().isEmpty ? 'admin' : userName.trim();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFBF2),
                Color(0xFFFFF7E6),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFE8D8B8),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x22C47A3D),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              _HeaderIconButton(
                icon: Icons.menu_rounded,
                onTap: onMenuTap,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'الحلاق',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _AnimatedCrownName(
                      displayName: displayName,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              _NotificationHeaderButton(
                unreadCount: unreadNotifications,
                onTap: onNotificationsTap,
              ),
            ],
          ),
        ),

        Positioned(
          left: 34,
          right: 34,
          bottom: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [
                  Color(0x00C47A3D),
                  Color(0xFFC47A3D),
                  Color(0x00C47A3D),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedCrownName extends StatefulWidget {
  const _AnimatedCrownName({
    required this.displayName,
  });

  final String displayName;

  @override
  State<_AnimatedCrownName> createState() => _AnimatedCrownNameState();
}

class _AnimatedCrownNameState extends State<_AnimatedCrownName>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.18,
      end: 0.42,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _floatAnimation = Tween<double>(
      begin: 1.5,
      end: -1.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFDF4D8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC47A3D).withValues(
                          alpha: _glowAnimation.value,
                        ),
                        blurRadius: 14,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 16,
                      color: Color(0xFFC28A2E),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 7),

        Flexible(
          child: Text(
            widget.displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFFC47A3D),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE7E5E4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF374151),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _NotificationHeaderButton extends StatelessWidget {
  const _NotificationHeaderButton({
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: onTap,
        ),

        if (unreadCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 19),
              height: 19,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white,
                  width: 1.6,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22EF4444),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}