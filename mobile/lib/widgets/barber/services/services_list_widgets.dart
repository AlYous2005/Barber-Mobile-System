import 'package:flutter/material.dart';

import '../../../features/barber/services_management/services_management.dart';
import '../../../general_utils/app_theme_colors.dart';

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

class ServicesTargetTabs extends StatelessWidget {
  const ServicesTargetTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ServiceTarget selected;
  final ValueChanged<ServiceTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color border = AppThemeColors.border(context);
    Widget tab(ServiceTarget target, String label) {
      final bool isOn = selected == target;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onChanged(target),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
              decoration: BoxDecoration(
                color: isOn
                    ? const Color(0xFFC47A3D).withValues(alpha: 0.14)
                    : AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOn ? const Color(0xFFC47A3D) : border,
                  width: isOn ? 1.6 : 1,
                ),
                boxShadow: isOn
                    ? const [
                        BoxShadow(
                          color: Color(0x18C47A3D),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: isOn
                      ? const Color(0xFFC47A3D)
                      : AppThemeColors.textSecondary(context),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab(ServiceTarget.personal, 'خدمات الشباب'),
        const SizedBox(width: 8),
        tab(ServiceTarget.child, 'خدمات الأطفال'),
        const SizedBox(width: 8),
        tab(ServiceTarget.elderly, 'خدمات كبار السن'),
      ],
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

class EmptyCategoryServicesState extends StatelessWidget {
  const EmptyCategoryServicesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Text(
        'لا توجد خدمات في هذه الفئة حاليًا',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.textSecondary(context),
        ),
      ),
    );
  }
}
