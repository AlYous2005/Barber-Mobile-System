import 'package:flutter/material.dart';

class SummaryFiltersCard extends StatelessWidget {
  const SummaryFiltersCard({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.selectedSpecificDate,
    required this.onSelect,
  });

  final List<String> filters;
  final int selectedFilter;
  final DateTime? selectedSpecificDate;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEADBCD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: Color(0xFF9A5A38),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'فلترة الملخصات',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(filters.length, (index) {
              final bool isSelected = selectedFilter == index;

              return FilterPillButton(
                label: index == 3 && selectedSpecificDate != null
                    ? '${selectedSpecificDate!.day}/${selectedSpecificDate!.month}/${selectedSpecificDate!.year}'
                    : filters[index],
                isSelected: isSelected,
                onTap: () => onSelect(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class FilterPillButton extends StatelessWidget {
  const FilterPillButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF9A5A38) : const Color(0xFFF7EEE6),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF9A5A38)
                  : const Color(0xFFE3D3C6),
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x229A5A38),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : const Color(0xFF6B4F3E),
            ),
          ),
        ),
      ),
    );
  }
}