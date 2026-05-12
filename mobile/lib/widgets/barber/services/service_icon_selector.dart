import 'package:flutter/material.dart';

import '../../../features/barber/services_management/services_management.dart';
import '../../../general_utils/app_theme_colors.dart';
import '../../shared/service_icon_view.dart';

class ServiceIconSelector extends StatelessWidget {
  const ServiceIconSelector({
    super.key,
    required this.selectedIconKey,
    required this.onChanged,
  });

  final String selectedIconKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'أيقونة الخدمة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppThemeColors.textSecondary(context),
          ),
        ),

        const SizedBox(height: 9),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Column(
            children: [
              Text(
                'اختر أيقونة مناسبة إذا لم ترفع صورة للخدمة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textMuted(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: ServiceIconOptions.all.map((option) {
                  final bool selected = option.key == selectedIconKey;

                  return _ServiceIconChoice(
                    option: option,
                    selected: selected,
                    onTap: () => onChanged(option.key),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceIconChoice extends StatelessWidget {
  const _ServiceIconChoice({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ServiceIconOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = AppThemeColors.brandBrown(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 62,
          height: 62,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: 0.12)
                : AppThemeColors.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? selectedColor : AppThemeColors.border(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: ServiceIconView(
              option: option,
              size: 38,
              fallbackColor: selected
                  ? selectedColor
                  : AppThemeColors.textSecondary(context),
              assetPadding: 1,
            ),
          ),
        ),
      ),
    );
  }
}
