import 'package:flutter/material.dart';

class AnimatedCrownName extends StatefulWidget {
  const AnimatedCrownName({super.key, required this.displayName});

  final String displayName;

  @override
  State<AnimatedCrownName> createState() => _AnimatedCrownNameState();
}

class _AnimatedCrownNameState extends State<AnimatedCrownName>
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.18,
      end: 0.42,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(
      begin: 1.5,
      end: -1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                child: _PremiumCrownBadge(glowOpacity: _glowAnimation.value),
              ),
            );
          },
        ),
        const SizedBox(width: 5),
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
        const SizedBox(width: 5),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _PremiumCrownBadge(glowOpacity: _glowAnimation.value),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PremiumCrownBadge extends StatelessWidget {
  const _PremiumCrownBadge({required this.glowOpacity});

  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(
              alpha: glowOpacity * 0.55,
            ),
            blurRadius: 14,
            spreadRadius: 1.2,
          ),
          BoxShadow(
            color: const Color(0xFFF6C453).withValues(
              alpha: glowOpacity * 0.35,
            ),
            blurRadius: 7,
            spreadRadius: 0.35,
          ),
        ],
      ),
      child: SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Image.asset(
          'assets/icons/premium_crown.png',
          width: 18,
          height: 18,
        ),
      ),
      ),
    );
  }
}
