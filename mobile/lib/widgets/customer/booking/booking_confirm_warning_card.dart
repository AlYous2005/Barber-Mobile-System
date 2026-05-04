import 'package:flutter/material.dart';

class BookingConfirmWarningCard extends StatelessWidget {
  const BookingConfirmWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14EF4444),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFDC2626),
            size: 23,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'راجع تفاصيل الحجز جيدًا. يمكنك الرجوع وتعديل أي خطوة قبل تأكيد الحجز النهائي.',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}