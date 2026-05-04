import 'package:flutter/material.dart';

import '../../shared/stat_card.dart';

class HomeStatsSection extends StatelessWidget {
  const HomeStatsSection({
    super.key,
    required this.selectedAppointmentFilter,
    required this.onFilterChanged,
  });

  final String selectedAppointmentFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'إحصائيات اليوم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            final int columns = width < 520 ? 2 : 4;
            final double aspectRatio = width < 380 ? 1.25 : 1.45;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: aspectRatio,
              ),
              children: [
                StatCard(
                  title: 'مواعيد معلقة',
                  value: '3',
                  color: const Color(0xFFF59E0B),
                  isSelected: selectedAppointmentFilter == 'معلقة',
                  onTap: () => onFilterChanged('معلقة'),
                ),
                StatCard(
                  title: 'مواعيد مؤكدة',
                  value: '9',
                  color: const Color(0xFF60A5FA),
                  isSelected: selectedAppointmentFilter == 'مؤكدة',
                  onTap: () => onFilterChanged('مؤكدة'),
                ),
                StatCard(
                  title: 'مواعيد مكتملة',
                  value: '7',
                  color: const Color(0xFF34D399),
                  isSelected: selectedAppointmentFilter == 'مكتملة',
                  onTap: () => onFilterChanged('مكتملة'),
                ),
                StatCard(
                  title: 'مواعيد ملغية',
                  value: '2',
                  color: const Color(0xFFF87171),
                  isSelected: selectedAppointmentFilter == 'ملغية',
                  onTap: () => onFilterChanged('ملغية'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}