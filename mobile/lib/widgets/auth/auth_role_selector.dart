import 'package:flutter/material.dart';

class AuthRoleSelector extends StatelessWidget {
  const AuthRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleButton(
            title: "زبون",
            icon: Icons.person,
            value: "customer",
            selectedRole: selectedRole,
            onTap: onRoleChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RoleButton(
            title: "حلاق",
            icon: Icons.content_cut,
            value: "barber",
            selectedRole: selectedRole,
            onTap: onRoleChanged,
          ),
        ),
      ],
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.title,
    required this.icon,
    required this.value,
    required this.selectedRole,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String value;
  final String selectedRole;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedRole == value;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.white24,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}