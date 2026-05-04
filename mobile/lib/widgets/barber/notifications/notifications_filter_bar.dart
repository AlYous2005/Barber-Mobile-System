import 'package:flutter/material.dart';

class NotificationsFilterBar extends StatelessWidget {
  const NotificationsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8D8B8),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChipButton(
            label: 'الكل',
            value: 'all',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          FilterChipButton(
            label: 'غير مقروء',
            value: 'unread',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          FilterChipButton(
            label: 'الحجوزات',
            value: 'appointments',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          FilterChipButton(
            label: 'النظام',
            value: 'system',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.value,
    required this.selectedFilter,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedFilter;

    return Material(
      color: isSelected ? const Color(0xFF9A5A38) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF9A5A38)
                  : const Color(0xFFE3D3C6),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : const Color(0xFF6B4F3E),
            ),
          ),
        ),
      ),
    );
  }
}