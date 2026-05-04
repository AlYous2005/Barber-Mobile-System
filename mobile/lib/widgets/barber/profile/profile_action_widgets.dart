import 'package:flutter/material.dart';

class EditActionsBar extends StatelessWidget {
  const EditActionsBar({
    super.key,
    required this.canSave,
    required this.onSave,
    required this.onCancel,
  });

  final bool canSave;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canSave ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC47A3D),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: Colors.white,
              disabledForegroundColor: const Color(0xFF9CA3AF),
              elevation: canSave ? 2 : 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'حفظ التعديلات',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111827),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class SheetActionButton extends StatelessWidget {
  const SheetActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
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