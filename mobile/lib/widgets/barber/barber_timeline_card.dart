import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';

class BarberTimelineCard extends StatefulWidget {
  const BarberTimelineCard({
    super.key,
    required this.currentAppointment,
    required this.upcomingAppointment,
    required this.showCurrent,
    required this.onToggle,
  });

  final MockAppointment? currentAppointment;
  final MockAppointment? upcomingAppointment;
  final bool showCurrent;
  final VoidCallback onToggle;

  @override
  State<BarberTimelineCard> createState() => _BarberTimelineCardState();
}

class _BarberTimelineCardState extends State<BarberTimelineCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  bool _isSwitching = false;
  bool _isCardDropping = false;

  MockAppointment? get _activeAppointment {
    return widget.showCurrent
        ? widget.currentAppointment
        : widget.upcomingAppointment;
  }

  bool get _canToggle {
    if (widget.showCurrent) {
      return widget.upcomingAppointment != null;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatClock(DateTime dateTime) {
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;

    final String period = hour >= 12 ? 'مساءً' : 'صباحًا';
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final String displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return '00:00';
    }

    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hh = hours.toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }

    return '$mm:$ss';
  }

  Future<void> _handleAnimatedToggle() async {
    if (!_canToggle || _isSwitching) return;

    setState(() {
      _isSwitching = true;
      _isCardDropping = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 140));

    if (!mounted) return;

    widget.onToggle();

    await Future<void>.delayed(const Duration(milliseconds: 260));

    if (!mounted) return;

    setState(() {
      _isCardDropping = false;
      _isSwitching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final MockAppointment? appointment = _activeAppointment;

    final bool isCurrentMode = widget.showCurrent;
    final bool hasAppointment = appointment != null;

    final Color mainStartColor = isCurrentMode
        ? const Color(0xFF9B6035)
        : const Color(0xFF114E79);
    final Color mainMiddleColor = isCurrentMode
        ? const Color(0xFFC98B53)
        : const Color(0xFF0E6BA8);
    final Color mainEndColor = isCurrentMode
        ? const Color(0xFFE7B679)
        : const Color(0xFF42BFF8);

    final Color switchColor = isCurrentMode
        ? const Color(0xFF0EA5E9)
        : const Color(0xFFF59E0B);

    final Color timerColor = isCurrentMode
        ? const Color(0xFFD9F99D)
        : const Color(0xFFBAE6FD);

    final String switchLabel = isCurrentMode ? 'القادم' : 'الحالي';

    final String titleText = hasAppointment
        ? appointment.customerName
        : isCurrentMode
        ? 'لا يوجد موعد حالياً'
        : 'لا يوجد موعد قادم';

    final String helperText = hasAppointment
        ? isCurrentMode
              ? 'متبقي حتى انتهاء الموعد'
              : 'باقي حتى بدء الموعد'
        : isCurrentMode
        ? 'جاهز لاستقبال الموعد القادم'
        : 'لا يوجد حجز قادم الآن';

    final String countdownText = hasAppointment
        ? isCurrentMode
              ? _formatCountdown(appointment.endDateTime.difference(_now))
              : _formatCountdown(appointment.startDateTime.difference(_now))
        : '—';

    final String timeRange = hasAppointment
        ? '${_formatClock(appointment.startDateTime)} — ${_formatClock(appointment.endDateTime)}'
        : '— — —';

    return Column(
      children: [
        AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          offset: _isCardDropping ? const Offset(0, 0.06) : Offset.zero,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            scale: _isCardDropping ? 0.985 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [mainStartColor, mainMiddleColor, mainEndColor],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: mainMiddleColor.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  const BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slideAnimation = Tween<Offset>(
                        begin: const Offset(0, -0.18),
                        end: Offset.zero,
                      ).animate(animation);

                      final scaleAnimation = Tween<double>(
                        begin: 1.04,
                        end: 1,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slideAnimation,
                          child: ScaleTransition(
                            scale: scaleAnimation,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey(
                        '${widget.showCurrent}-${appointment?.id ?? 'empty'}',
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusBadge(
                            isCurrentMode: isCurrentMode,
                            hasAppointment: hasAppointment,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [
                            const _RadarCircle(),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: _MarqueeText(
                                      text: titleText,
                                      shouldAnimate: titleText.length > 12,
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),

                                  if (hasAppointment && !isCurrentMode) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      appointment.serviceName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(
                                          alpha: 0.82,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      helperText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white.withValues(
                                          alpha: 0.86,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 128,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.10,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      countdownText,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: timerColor,
                                        height: 1,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      textDirection: TextDirection.ltr,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 14,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          timeRange,
                                          textDirection: TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white.withValues(
                                              alpha: 0.94,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white.withValues(alpha: 0.88),
                              size: 28,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Transform.translate(
          offset: const Offset(0, 0),
          child: InkWell(
            onTap: _canToggle ? _handleAnimatedToggle : null,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(999),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _canToggle ? 1 : 0.42,
              child: Container(
                width: 112,
                height: 72,
                decoration: BoxDecoration(
                  color: switchColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(999),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: switchColor.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      switchLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isCurrentMode,
    required this.hasAppointment,
  });

  final bool isCurrentMode;
  final bool hasAppointment;

  @override
  Widget build(BuildContext context) {
    final String text = hasAppointment
        ? isCurrentMode
              ? 'جارية'
              : 'قادم'
        : 'متاح';

    final Color color = hasAppointment
        ? isCurrentMode
              ? const Color(0xFF84CC16)
              : const Color(0xFF38BDF8)
        : const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarCircle extends StatefulWidget {
  const _RadarCircle();

  @override
  State<_RadarCircle> createState() => _RadarCircleState();
}

class _RadarCircleState extends State<_RadarCircle>
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
                        color: const Color(
                          0xFF84CC16,
                        ).withValues(alpha: _glowAnimation.value),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: const Color(
                          0xFFBEF264,
                        ).withValues(alpha: _glowAnimation.value * 0.55),
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

class _MarqueeText extends StatefulWidget {
  const _MarqueeText({
    required this.text,
    required this.style,
    required this.shouldAnimate,
  });

  final String text;
  final TextStyle style;
  final bool shouldAnimate;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
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
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
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
