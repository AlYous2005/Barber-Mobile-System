import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class CurrentServicesBanner extends StatelessWidget {
  const CurrentServicesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = AppThemeColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? const <Color>[Color(0xFF1A3D2A), Color(0xFF14532D)]
              : const <Color>[Color(0xFFEFFCF3), Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: dark
              ? const Color(0xFF22C55E).withValues(alpha: 0.35)
              : const Color(0xFFB7EFC5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF22C55E,
            ).withValues(alpha: dark ? 0.12 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF16A34A), Color(0xFF15803D)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3316A34A),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخدمات الحالية',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: dark
                        ? AppThemeColors.textPrimary(context)
                        : const Color(0xFF5C4030),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'جميع الخدمات المتوفرة حالياً للحلاق مع المدة والسعر وخيارات الإدارة',
                  style: TextStyle(
                    fontSize: 13,
                    color: dark
                        ? AppThemeColors.textSecondary(context)
                        : const Color(0xFF166534),
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyServicesState extends StatelessWidget {
  const EmptyServicesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Text(
        'لا توجد خدمات مضافة حاليًا',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.textSecondary(context),
        ),
      ),
    );
  }
}
