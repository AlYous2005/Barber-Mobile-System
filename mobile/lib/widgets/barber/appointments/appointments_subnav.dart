import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class AppointmentsSubnav extends StatelessWidget {
  const AppointmentsSubnav({
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
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SubnavButton(
              label: 'مواعيد اليوم',
              icon: Icons.calendar_today_rounded,
              isActive: selectedTab == 'today',
              onTap: () => onChanged('today'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SubnavButton(
              label: 'حجوزات أخرى',
              icon: Icons.date_range_rounded,
              isActive: selectedTab == 'other',
              onTap: () => onChanged('other'),
            ),
          ),
        ],
      ),
    );
  }
}

class SubnavButton extends StatelessWidget {
  const SubnavButton({
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
    final Color activeColor = const Color(0xFF8F4E2C);

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
                      color: Color(0x228F4E2C),
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
                color: isActive
                    ? Colors.white
                    : AppThemeColors.textSecondary(context),
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
                    color: isActive
                        ? Colors.white
                        : AppThemeColors.textSecondary(context),
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
