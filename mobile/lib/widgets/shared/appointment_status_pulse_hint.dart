import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/bookings/models/appointment_cancelled_by.dart';
import '../../features/bookings/models/appointment_status_audience.dart';
import '../../features/bookings/utils/appointment_status_badge_style.dart';
import '../../features/bookings/utils/appointment_status_hint_texts.dart';
import '../../general_utils/app_theme_colors.dart';

/// Status badge with a light pulse + glow; tap shows [Tooltip] when [hintMessage] is non-null.
///
/// Prefer this over many `AnimationController`s on large grids: disables pulse when no hint,
/// wraps paint in [RepaintBoundary].
class AppointmentStatusPulseHint extends StatefulWidget {
  const AppointmentStatusPulseHint({
    super.key,
    required this.arabicStatus,
    required this.audience,
    this.cancelledBy,
    this.styleResolver = AppointmentStatusBadgeStyle.fromArabicStatus,
    this.dense = false,
  });

  final String arabicStatus;
  final AppointmentStatusAudience audience;
  final AppointmentCancelledBy? cancelledBy;

  /// Customer card passes a richer resolver for backwards-compatible colors.
  final AppointmentStatusBadgeStyle Function(String status) styleResolver;

  final bool dense;

  @override
  State<AppointmentStatusPulseHint> createState() =>
      _AppointmentStatusPulseHintState();
}

class _AppointmentStatusPulseHintState extends State<AppointmentStatusPulseHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _isBubbleVisible = false;
  Timer? _hideBubbleTimer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant AppointmentStatusPulseHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.arabicStatus != widget.arabicStatus ||
        oldWidget.audience != widget.audience ||
        oldWidget.cancelledBy != widget.cancelledBy) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    final String? hint = _hintText;
    if (hint == null && _isBubbleVisible) {
      _hideBubble(immediate: true);
    }

    if (hint == null) {
      _pulse.stop();
      _pulse.value = 0;
    } else {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    }
  }

  String? get _hintText {
    final String? hint = AppointmentStatusHintTexts.resolve(
      audience: widget.audience,
      arabicStatus: widget.arabicStatus,
      cancelledBy: widget.cancelledBy,
    );
    return hint;
  }

  void _showBubble() {
    _hideBubbleTimer?.cancel();
    if (!_isBubbleVisible) {
      setState(() {
        _isBubbleVisible = true;
      });
    }
    _hideBubbleTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      _hideBubble(immediate: false);
    });
  }

  void _hideBubble({required bool immediate}) {
    _hideBubbleTimer?.cancel();
    if (_isBubbleVisible) {
      setState(() {
        _isBubbleVisible = false;
      });
    }
  }

  void _toggleBubble() {
    if (_hintText == null) return;
    if (_isBubbleVisible) {
      _hideBubble(immediate: true);
      return;
    }
    _showBubble();
  }

  @override
  void dispose() {
    _hideBubbleTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppointmentStatusBadgeStyle style =
        widget.styleResolver(widget.arabicStatus);
    final String? hint = _hintText;

    final Widget badge = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          final double t = hint == null ? 0 : _pulse.value;
          final double scale = 1 + 0.028 * t;
          final double glow = 0.08 + 0.12 * t;

          return Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.dense ? 8 : 12,
                vertical: widget.dense ? 6 : 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: style.gradientColors),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: style.borderColor.withValues(alpha: 0.22 + 0.08 * t),
                ),
                boxShadow: [
                  BoxShadow(
                    color: style.foregroundColor.withValues(alpha: glow),
                    blurRadius: 10 + 8 * t,
                    spreadRadius: 0.5 * t,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              style.icon,
              size: widget.dense ? 14 : 16,
              color: style.foregroundColor,
            ),
            SizedBox(width: widget.dense ? 4 : 6),
            Text(
              style.shortLabel,
              style: TextStyle(
                color: style.foregroundColor,
                fontSize: widget.dense ? 11 : 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );

    if (hint == null) {
      return badge;
    }

    final bool dark = AppThemeColors.isDark(context);
    final Color bubbleBackground = dark
        ? AppThemeColors.elevatedCard(context)
        : const Color(0xFFFFF7EE);
    final Color bubbleBorder = dark
        ? AppThemeColors.border(context)
        : const Color(0xFFF0D2B2);

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleBubble,
            child: badge,
          ),
          PositionedDirectional(
            bottom: widget.dense ? 36 : 44,
            start: 0,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                opacity: _isBubbleVisible ? 1 : 0,
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                child: AnimatedScale(
                  scale: _isBubbleVisible ? 1 : 0.92,
                  duration: const Duration(milliseconds: 190),
                  curve: Curves.easeOutBack,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 190),
                    curve: Curves.easeOutCubic,
                    offset: _isBubbleVisible
                        ? Offset.zero
                        : const Offset(0, 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 240),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: bubbleBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: dark ? 0.28 : 0.12,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            hint,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsetsDirectional.only(start: 18),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: bubbleBackground,
                            border: Border(
                              right: BorderSide(color: bubbleBorder),
                              bottom: BorderSide(color: bubbleBorder),
                            ),
                          ),
                          transform: Matrix4.rotationZ(0.785398),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
