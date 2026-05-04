import 'package:flutter/material.dart';

class TimelineMarqueeText extends StatefulWidget {
  const TimelineMarqueeText({
    super.key,
    required this.text,
    required this.style,
    required this.shouldAnimate,
  });

  final String text;
  final TextStyle style;
  final bool shouldAnimate;

  @override
  State<TimelineMarqueeText> createState() => _TimelineMarqueeTextState();
}

class _TimelineMarqueeTextState extends State<TimelineMarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.90, 0),
      end: const Offset(-0.90, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    if (widget.shouldAnimate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant TimelineMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    }

    if (!widget.shouldAnimate && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldAnimate) {
      return Center(
        child: Text(
          widget.text,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: widget.style,
        ),
      );
    }

    return ClipRect(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Center(
          child: Text(
            widget.text,
            maxLines: 1,
            softWrap: false,
            style: widget.style,
          ),
        ),
      ),
    );
  }
}
