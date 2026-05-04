import 'package:flutter/material.dart';

Future<bool?> showCancelAppointmentDialog({
  required BuildContext context,
  required String barberName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'إلغاء الموعد',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد إلغاء موعدك عند الحلاق $barberName؟',
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'تراجع',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'إلغاء الموعد',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    },
  );
}