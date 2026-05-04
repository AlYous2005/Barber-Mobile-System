import 'package:flutter/material.dart';

class TimelineRadarCircle extends StatefulWidget {
  const TimelineRadarCircle({super.key});

  @override
  State<TimelineRadarCircle> createState() => _TimelineRadarCircleState();
}

class _TimelineRadarCircleState extends State<TimelineRadarCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFFFD8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF84CC16).withValues(
                          alpha: _glowAnimation.value,
                        ),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: const Color(0xFFBEF264).withValues(
                          alpha: _glowAnimation.value * 0.55,
                        ),
                        blurRadius: 34,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: Color(0xFF65A30D),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}