import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class CustomerProfileTextField extends StatelessWidget {
  const CustomerProfileTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = AppThemeColors.isDark(context)
        ? AppThemeColors.softCard(context)
        : const Color(0xFFF9FBFA);
    final Color borderColor = AppThemeColors.border(context);

    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF5C4030)),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFC47A3D),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomerCountryDropdown extends StatelessWidget {
  const CustomerCountryDropdown({
    super.key,
    required this.selectedCountry,
    required this.onChanged,
  });

  final String selectedCountry;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = AppThemeColors.isDark(context)
        ? AppThemeColors.softCard(context)
        : const Color(0xFFF9FBFA);
    final Color borderColor = AppThemeColors.border(context);

    return Column(
      children: [
        Text(
          'الدولة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(
          initialValue: selectedCountry,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFC47A3D),
                width: 1.4,
              ),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'فلسطين', child: Text('🇵🇸 +970')),
            DropdownMenuItem(value: 'إسرائيل', child: Text('🇮🇱 +972')),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class CustomerPasswordField extends StatelessWidget {
  const CustomerPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  final String label;
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = AppThemeColors.isDark(context)
        ? AppThemeColors.softCard(context)
        : const Color(0xFFF9FBFA);
    final Color borderColor = AppThemeColors.border(context);

    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF5C4030),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFC47A3D),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
