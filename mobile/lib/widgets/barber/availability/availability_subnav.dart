import 'package:flutter/material.dart';

class AvailabilitySubnav extends StatelessWidget {
  const AvailabilitySubnav({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  final String selectedTab;
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
      child: Row(
        children: [
          Expanded(
            child: AvailabilitySubnavButton(
              label: 'إغلاقات الأيام',
              icon: Icons.calendar_month_rounded,
              isActive: selectedTab == 'closures',
              onTap: () => onChanged('closures'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AvailabilitySubnavButton(
              label: 'فترات عدم التوفر',
              icon: Icons.access_time_rounded,
              isActive: selectedTab == 'time_blocks',
              onTap: () => onChanged('time_blocks'),
            ),
          ),
        ],
      ),
    );
  }
}

class AvailabilitySubnavButton extends StatelessWidget {
  const AvailabilitySubnavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF9A5A38);

    return Material(
      color: isActive ? activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x229A5A38),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isActive ? Colors.white : const Color(0xFF6B5D52),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : const Color(0xFF6B5D52),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}