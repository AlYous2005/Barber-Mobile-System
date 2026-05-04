import 'package:flutter/material.dart';

class AppointmentsTabsSelector extends StatelessWidget {
  const AppointmentsTabsSelector({
    super.key,
    required this.selectedTab,
    required this.upcomingCount,
    required this.previousCount,
    required this.onTabChanged,
  });

  final String selectedTab;
  final int upcomingCount;
  final int previousCount;
  final ValueChanged<String> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEADBCD)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AppointmentTabButton(
              title: 'القادمة',
              count: upcomingCount,
              icon: Icons.event_available_rounded,
              isSelected: selectedTab == 'upcoming',
              onTap: () => onTabChanged('upcoming'),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _AppointmentTabButton(
              title: 'السابقة',
              count: previousCount,
              icon: Icons.history_rounded,
              isSelected: selectedTab == 'previous',
              onTap: () => onTabChanged('previous'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTabButton extends StatelessWidget {
  const _AppointmentTabButton({
    required this.title,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFC47A3D);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x22C47A3D),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : activeColor,
                size: 20,
              ),

              const SizedBox(width: 7),

              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B4F3E),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : activeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : activeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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