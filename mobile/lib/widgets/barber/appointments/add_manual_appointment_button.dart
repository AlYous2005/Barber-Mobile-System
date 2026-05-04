import 'package:flutter/material.dart';

class AddManualAppointmentButton extends StatelessWidget {
  const AddManualAppointmentButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC47A3D),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9A5A38),
                Color(0xFFB8774A),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3020532D),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'إضافة موعد يدوي',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}