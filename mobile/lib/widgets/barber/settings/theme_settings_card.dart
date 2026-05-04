import 'package:flutter/material.dart';

import 'settings_shared_widgets.dart';

class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsCardShell(
      child: Column(
        children: [
          Row(
            children: [
              SettingsIconBox(
                icon: isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: isDarkMode
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFF59E0B),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مظهر التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'اختر بين الوضع الفاتح أو الداكن حسب راحتك أثناء العمل.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
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
              color: const Color(0xFFF8F3ED),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8D8B8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ThemeModeButton(
                    label: 'Light',
                    icon: Icons.light_mode_rounded,
                    isActive: !isDarkMode,
                    onTap: () => onChanged(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeModeButton(
                    label: 'Dark',
                    icon: Icons.dark_mode_rounded,
                    isActive: isDarkMode,
                    onTap: () => onChanged(true),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          StatusPill(
            label: isDarkMode
                ? 'الوضع الداكن مختار حاليًا'
                : 'الوضع الفاتح مختار حاليًا',
            color: isDarkMode
                ? const Color(0xFF6366F1)
                : const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF9A5A38);

    return Material(
      color: isActive ? activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x229A5A38),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isActive ? Colors.white : const Color(0xFF6B5D52),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : const Color(0xFF6B5D52),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}