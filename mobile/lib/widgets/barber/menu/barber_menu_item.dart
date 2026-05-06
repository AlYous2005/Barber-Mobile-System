import 'package:flutter/material.dart';

class BarberMenuItem extends StatelessWidget {
  const BarberMenuItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isSelected
        ? const Color(0xFFC47A3D)
        : const Color(0xFF8B6B55);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: isSelected
            ? const Color(0xFFC47A3D).withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC47A3D).withValues(alpha: 0.32)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFFF2C99A)
                        : const Color(0xFFBFA898),
                    size: 19,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

                Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
