import 'package:flutter/material.dart';

class TimelineStatusBadge extends StatelessWidget {
  const TimelineStatusBadge({
    super.key,
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
        : 'جارية';

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
