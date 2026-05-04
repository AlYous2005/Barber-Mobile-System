import 'package:flutter/material.dart';

class AvailabilitySheetHandle extends StatelessWidget {
  const AvailabilitySheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class AvailabilitySheetHeader extends StatelessWidget {
  const AvailabilitySheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFC47A3D),
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: const Color(0xFFF5F5F4),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onClose,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ),
      ],
    );
  }
}