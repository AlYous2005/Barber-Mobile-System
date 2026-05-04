import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class BookingStepHeader extends StatelessWidget {
  const BookingStepHeader({super.key, required this.step, required this.title});

  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    final int currentStep = step + 1;
    final double progress = currentStep / 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppThemeColors.textPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الخطوة $currentStep من 5',
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppThemeColors.softCard(context),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppThemeColors.border(context)),
                ),
                child: Text(
                  '$currentStep/5',
                  style: const TextStyle(
                    color: Color(0xFFC47A3D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              width: double.infinity,
              color: AppThemeColors.softCard(context),
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC47A3D), Color(0xFFFFB45C)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
