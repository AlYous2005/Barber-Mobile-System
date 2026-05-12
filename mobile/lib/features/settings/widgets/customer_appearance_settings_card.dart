import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import 'customer_settings_shared_widgets.dart';

class CustomerAppearanceSettingsCard extends StatelessWidget {
  const CustomerAppearanceSettingsCard({
    super.key,
    required this.isDarkMode,
    required this.onSelectLight,
    required this.onSelectDark,
  });

  final bool isDarkMode;
  final VoidCallback onSelectLight;
  final VoidCallback onSelectDark;

  @override
  Widget build(BuildContext context) {
    return CustomerSettingsCardShell(
      child: Column(
        children: [
          Row(
            children: [
              CustomerSettingsIconBox(
                icon: isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: isDarkMode
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نمط التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اختر النمط الفاتح أو الداكن حسب راحتك أثناء استخدام التطبيق.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppThemeColors.softCard(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppThemeColors.border(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomerThemeModeButton(
                    label: 'فاتح',
                    icon: Icons.light_mode_rounded,
                    isActive: !isDarkMode,
                    onTap: onSelectLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomerThemeModeButton(
                    label: 'داكن',
                    icon: Icons.dark_mode_rounded,
                    isActive: isDarkMode,
                    onTap: onSelectDark,
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
