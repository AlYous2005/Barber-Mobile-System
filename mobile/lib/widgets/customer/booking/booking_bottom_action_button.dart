import 'package:flutter/material.dart';

class BookingBottomActionButton extends StatelessWidget {
  const BookingBottomActionButton({
    super.key,
    required this.isConfirmStep,
    required this.canContinue,
    required this.onPressed,
  });

  final bool isConfirmStep;
  final bool canContinue;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canContinue ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC47A3D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: Text(
          isConfirmStep ? 'تأكيد الحجز' : 'التالي',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}