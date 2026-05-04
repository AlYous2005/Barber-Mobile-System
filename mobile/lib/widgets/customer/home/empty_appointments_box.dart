import 'package:flutter/material.dart';

class EmptyAppointmentsBox extends StatelessWidget {
  const EmptyAppointmentsBox({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}