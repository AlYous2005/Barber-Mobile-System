import 'package:flutter/material.dart';

class NotificationHeaderButton extends StatefulWidget {
  const NotificationHeaderButton({
    super.key,
    required this.unreadCount,
    required this.onTap,
    this.shouldAnimate = false,
    this.onAnimationConsumed,
  });

  final int unreadCount;
  final VoidCallback onTap;
  final bool shouldAnimate;
  final VoidCallback? onAnimationConsumed;

  @override
  State<NotificationHeaderButton> createState() => _NotificationHeaderButtonState();
}

class _NotificationHeaderButtonState extends State<NotificationHeaderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _shakeAnimation;
  bool _consumedCurrentCycle = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -3.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.5, end: 3.5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3.5, end: -2.4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.4, end: 2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0), weight: 2),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant NotificationHeaderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldAnimate != widget.shouldAnimate) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (!widget.shouldAnimate) {
      _animationController.stop();
      _animationController.value = 0;
      _consumedCurrentCycle = false;
      return;
    }
    if (_animationController.isAnimating) {
      return;
    }
    _consumedCurrentCycle = false;
    _animationController.forward(from: 0).whenComplete(() {
      if (!mounted || _consumedCurrentCycle) {
        return;
      }
      _consumedCurrentCycle = true;
      widget.onAnimationConsumed?.call();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color highlightColor = Color(0xFFF59E0B);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final bool isActive = widget.shouldAnimate;
            final double glowStrength = isActive
                ? (0.45 + (0.55 * (1 - _animationController.value)))
                : 0;
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: highlightColor.withValues(
                          alpha: 0.22 * glowStrength,
                        ),
                        blurRadius: 18,
                        spreadRadius: 2.5,
                      ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive
                              ? highlightColor.withValues(alpha: 0.65)
                              : const Color(0xFFE7E5E4),
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
                        Icons.notifications_none_rounded,
                        color: isActive
                            ? highlightColor
                            : const Color(0xFF374151),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.unreadCount > 0)
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
                border: Border.all(color: Colors.white, width: 1.6),
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
                widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
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
