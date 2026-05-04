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

class CustomerPasswordField extends StatefulWidget {
  const CustomerPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
    this.errorText,
    this.shakeTrigger = 0,
  });

  final String label;
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  /// Inline validation message; red border when non-empty.
  final String? errorText;

  /// Increment from parent to replay a subtle horizontal shake.
  final int shakeTrigger;

  @override
  State<CustomerPasswordField> createState() => _CustomerPasswordFieldState();
}

class _CustomerPasswordFieldState extends State<CustomerPasswordField>
    with SingleTickerProviderStateMixin {
  static const Color _errorColor = Color(0xFFEF4444);

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeOffset =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem(tween: Tween<double>(begin: 0, end: -5), weight: 1),
          TweenSequenceItem(tween: Tween<double>(begin: -5, end: 5), weight: 1),
          TweenSequenceItem(tween: Tween<double>(begin: 5, end: -4), weight: 1),
          TweenSequenceItem(tween: Tween<double>(begin: -4, end: 4), weight: 1),
          TweenSequenceItem(tween: Tween<double>(begin: 4, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(covariant CustomerPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger &&
        widget.shakeTrigger > 0) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color fillColor = AppThemeColors.isDark(context)
        ? AppThemeColors.softCard(context)
        : const Color(0xFFF9FBFA);
    final Color borderColor = AppThemeColors.border(context);

    final String? trimmedError = widget.errorText?.trim();
    final bool hasError = trimmedError != null && trimmedError.isNotEmpty;
    final Color effectiveBorder = hasError ? _errorColor : borderColor;
    final Color focusBorder = hasError ? _errorColor : const Color(0xFFC47A3D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 9),
        AnimatedBuilder(
          animation: _shakeOffset,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeOffset.value, 0),
              child: child,
            );
          },
          child: TextField(
            controller: widget.controller,
            obscureText: !widget.isVisible,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF5C4030),
              ),
              suffixIcon: IconButton(
                onPressed: widget.onToggleVisibility,
                icon: Icon(
                  widget.isVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppThemeColors.textSecondary(context),
                ),
              ),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: effectiveBorder,
                  width: hasError ? 1.4 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: effectiveBorder,
                  width: hasError ? 1.4 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: focusBorder, width: 1.4),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            trimmedError,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _errorColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
