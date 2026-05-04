import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/mock_service.dart';
import '../../../utils/app_theme_colors.dart';

class ManualAppointmentTextField extends StatelessWidget {
  const ManualAppointmentTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.hasError = false,
    this.shakeTrigger = 0,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final bool hasError;
  final int shakeTrigger;

  @override
  Widget build(BuildContext context) {
    const Color errorColor = Color(0xFFEF4444);

    return ShakeOnChange(
      trigger: shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            focusNode: focusNode,
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              errorStyle: const TextStyle(
                color: errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              prefixIcon: Icon(icon, color: AppThemeColors.brandBrown(context)),
              filled: true,
              fillColor: AppThemeColors.softCard(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: hasError ? errorColor : AppThemeColors.border(context),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: hasError ? errorColor : AppThemeColors.border(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: hasError ? errorColor : const Color(0xFFC47A3D),
                  width: 1.4,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: errorColor, width: 1.4),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: errorColor, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ManualServiceDropdown extends StatelessWidget {
  const ManualServiceDropdown({
    super.key,
    required this.selectedServiceName,
    required this.onChanged,
    this.errorText,
    this.hasError = false,
    this.shakeTrigger = 0,
  });

  final String? selectedServiceName;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool hasError;
  final int shakeTrigger;

  @override
  Widget build(BuildContext context) {
    const Color errorColor = Color(0xFFEF4444);

    return ShakeOnChange(
      trigger: shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'نوع الخدمة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppThemeColors.softCard(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasError ? errorColor : AppThemeColors.border(context),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedServiceName,
                isExpanded: true,
                hint: Text(
                  'اختر الخدمة',
                  style: TextStyle(color: AppThemeColors.textMuted(context)),
                ),
                items: mockBarberServices.map((service) {
                  return DropdownMenuItem<String>(
                    value: service.name,
                    child: Text(
                      '${service.name} - ${service.durationMinutes} دقيقة',
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: const TextStyle(
                color: errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PickerBox extends StatelessWidget {
  const PickerBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.errorText,
    this.hasError = false,
    this.shakeTrigger = 0,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;
  final bool hasError;
  final int shakeTrigger;

  @override
  Widget build(BuildContext context) {
    const Color errorColor = Color(0xFFEF4444);

    return ShakeOnChange(
      trigger: shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 9),
          Material(
            color: AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: hasError
                        ? errorColor
                        : AppThemeColors.border(context),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: AppThemeColors.brandBrown(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: const TextStyle(
                color: errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ShakeOnChange extends StatelessWidget {
  const ShakeOnChange({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOut,
      builder: (context, value, childWidget) {
        final double offset = math.sin(value * math.pi * 6) * (1 - value) * 10;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: childWidget,
        );
      },
      child: child,
    );
  }
}

class ManualPrimaryButton extends StatelessWidget {
  const ManualPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC47A3D),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
