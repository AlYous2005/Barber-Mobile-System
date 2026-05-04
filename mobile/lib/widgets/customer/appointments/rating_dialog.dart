import 'package:flutter/material.dart';

Future<int?> showCustomerRatingDialog({
  required BuildContext context,
  required String barberName,
  required double barberRating,
}) {
  int selectedStars = 5;

  return showDialog<int>(
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
            'قيّم الحلاق',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الحلاق $barberName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'تقييمه الحالي ${barberRating.toStringAsFixed(1)} ★',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final value = index + 1;

                      return IconButton(
                        onPressed: () {
                          setInnerState(() {
                            selectedStars = value;
                          });
                        },
                        icon: Icon(
                          value <= selectedStars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 30,
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedStars),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC47A3D),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'إرسال',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    },
  );
}