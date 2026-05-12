import 'dart:async';

import 'package:flutter/material.dart';

import '../../../features/bookings/bookings.dart';
import '../../../general_utils/app_theme_colors.dart';

import 'timeline_marquee_text.dart';
import 'timeline_radar_circle.dart';
import 'timeline_status_badge.dart';

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
    final bool isDark = AppThemeColors.isDark(context);

    final Color mainStartColor = isDark
        ? (isCurrentMode ? const Color(0xFF2A1810) : const Color(0xFF0C2433))
        : (isCurrentMode ? const Color(0xFF9B6035) : const Color(0xFF114E79));
    final Color mainMiddleColor = isDark
        ? (isCurrentMode ? const Color(0xFF4A3020) : const Color(0xFF143D55))
        : (isCurrentMode ? const Color(0xFFC98B53) : const Color(0xFF0E6BA8));
    final Color mainEndColor = isDark
        ? (isCurrentMode ? const Color(0xFF52321E) : const Color(0xFF1A4D6A))
        : (isCurrentMode ? const Color(0xFFE7B679) : const Color(0xFF42BFF8));

    final Color switchColor = isDark
        ? (isCurrentMode ? const Color(0xFFB86A3D) : const Color(0xFFD97706))
        : (isCurrentMode ? const Color(0xFF0EA5E9) : const Color(0xFFF59E0B));

    final Color timerColor = isDark
        ? (isCurrentMode ? const Color(0xFFEED9B8) : const Color(0xFFB8E0F2))
        : (isCurrentMode ? const Color(0xFFD9F99D) : const Color(0xFFBAE6FD));

    final String switchLabel = isCurrentMode ? 'القادم' : 'الحالي';

    final String titleText = hasAppointment
        ? appointment.displayCustomerName
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
        ? formatArabicAppointmentTimeRange(
            appointment.startDateTime,
            appointment.endDateTime,
          )
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
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [
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
                          child: TimelineStatusBadge(
                            isCurrentMode: isCurrentMode,
                            hasAppointment: hasAppointment,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [
                            const TimelineRadarCircle(),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: TimelineMarqueeText(
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
                    color: isDark
                        ? const Color(0xFFF8F3ED).withValues(alpha: 0.14)
                        : Colors.white.withValues(alpha: 0.55),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.45)
                          : switchColor.withValues(alpha: 0.28),
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
