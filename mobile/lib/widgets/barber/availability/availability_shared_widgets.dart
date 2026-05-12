import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class AvailabilityPickerBox extends StatelessWidget {
  const AvailabilityPickerBox({
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
    return AvailabilityShakeOnChange(
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

class AvailabilityTextInputBox extends StatelessWidget {
  const AvailabilityTextInputBox({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.errorText,
    this.hasError = false,
    this.shakeTrigger = 0,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? errorText;
  final bool hasError;
  final int shakeTrigger;

  @override
  Widget build(BuildContext context) {
    const Color errorColor = Color(0xFFEF4444);
    return AvailabilityShakeOnChange(
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

class AvailabilityShakeOnChange extends StatelessWidget {
  const AvailabilityShakeOnChange({
    super.key,
    required this.trigger,
    required this.child,
  });

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

class AvailabilityInfoBox extends StatelessWidget {
  const AvailabilityInfoBox({
    super.key,
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppThemeColors.textSecondary(context), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.6,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AvailabilityPrimaryButton extends StatelessWidget {
  const AvailabilityPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;
    final Color backgroundColor = isEnabled
        ? color
        : AppThemeColors.softCard(context);
    final Color borderColor = isEnabled
        ? color
        : AppThemeColors.border(context);
    final Color iconAndTextColor = isEnabled
        ? Colors.white
        : AppThemeColors.textMuted(context);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconAndTextColor, size: 17),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: iconAndTextColor,
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

class AvailabilitySecondaryButton extends StatelessWidget {
  const AvailabilitySecondaryButton({
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
      color: AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppThemeColors.textPrimary(context), size: 17),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
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

class AvailabilityModeSwitch extends StatelessWidget {
  const AvailabilityModeSwitch({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  final String selectedMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AvailabilityModeChip(
            label: 'يتكرر في أيام الدوام',
            isActive: selectedMode == 'recurring',
            onTap: () => onChanged('recurring'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AvailabilityModeChip(
            label: 'ليوم محدد',
            isActive: selectedMode == 'specific',
            onTap: () => onChanged('specific'),
          ),
        ),
      ],
    );
  }
}

class AvailabilityModeChip extends StatelessWidget {
  const AvailabilityModeChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFFFF3C4) : AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFC4A15F)
                  : AppThemeColors.border(context),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isActive
                  ? const Color(0xFF92400E)
                  : AppThemeColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}

class AvailabilityAddCardShell extends StatelessWidget {
  const AvailabilityAddCardShell({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppThemeColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? AppThemeColors.card(context) : null,
        gradient: dark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFFBFFFC), Color(0xFFF5FBF7)],
              ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
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
                    colors: [Color(0xFF9A5A38), Color(0xFFB8774A)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3020532D),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: dark
                            ? AppThemeColors.textPrimary(context)
                            : const Color(0xFF5C4030),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
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
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
