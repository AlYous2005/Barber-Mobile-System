import 'package:flutter/material.dart';

class HomeAppointmentsHeader extends StatelessWidget {
  const HomeAppointmentsHeader({
    super.key,
    required this.title,
    required this.onShowAll,
  });

  final String title;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
          ),
          GestureDetector(
            onTap: onShowAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330EA5E9),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                'كل مواعيد اليوم',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class HomeAppointmentsEmptyState extends StatelessWidget {
  const HomeAppointmentsEmptyState({
    super.key,
    required this.selectedAppointmentFilter,
  });

  final String selectedAppointmentFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        selectedAppointmentFilter == 'الكل'
            ? 'لا توجد مواعيد اليوم'
            : 'لا توجد مواعيد ضمن هذا القسم',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}