import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/barber/services_management/services_management.dart';

import '../../../general_utils/app_theme_colors.dart';

class ServiceTextField extends StatefulWidget {
  const ServiceTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.errorText,
    this.shakeTrigger = 0,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? errorText;
  final int shakeTrigger;

  @override
  State<ServiceTextField> createState() => _ServiceTextFieldState();
}

class _ServiceTextFieldState extends State<ServiceTextField>
    with SingleTickerProviderStateMixin {
  static const Color _errorColor = Color(0xFFEF4444);

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
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
  void didUpdateWidget(covariant ServiceTextField oldWidget) {
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
    final String? trimmed = widget.errorText?.trim();
    final bool hasError = trimmed != null && trimmed.isNotEmpty;
    final Color fill = AppThemeColors.softCard(context);
    final Color borderNormal = AppThemeColors.border(context);
    final Color borderUse = hasError ? _errorColor : borderNormal;
    final Color focusBorder = hasError
        ? _errorColor
        : AppThemeColors.brandBrown(context);

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
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: AppThemeColors.textMuted(context)),
              prefixIcon: Icon(
                widget.icon,
                color: const Color(0xFF5C4030),
                size: 20,
              ),
              filled: true,
              fillColor: fill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: borderUse,
                  width: hasError ? 1.4 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: borderUse,
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
            trimmed,
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

class NumberStepperField extends StatefulWidget {
  const NumberStepperField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onIncrease,
    required this.onDecrease,
    this.errorText,
    this.shakeTrigger = 0,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final String? errorText;
  final int shakeTrigger;

  @override
  State<NumberStepperField> createState() => _NumberStepperFieldState();
}

class _NumberStepperFieldState extends State<NumberStepperField>
    with SingleTickerProviderStateMixin {
  static const Color _errorColor = Color(0xFFEF4444);

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
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
  void didUpdateWidget(covariant NumberStepperField oldWidget) {
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
    final String? trimmed = widget.errorText?.trim();
    final bool hasError = trimmed != null && trimmed.isNotEmpty;
    final Color fill = AppThemeColors.softCard(context);
    final Color borderNormal = AppThemeColors.border(context);
    final Color borderUse = hasError ? _errorColor : borderNormal;
    final Color focusBorder = hasError
        ? _errorColor
        : AppThemeColors.brandBrown(context);

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
          child: Row(
            children: [
              AdjustButton(
                icon: Icons.remove_rounded,
                onTap: widget.onDecrease,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: AppThemeColors.textMuted(context),
                    ),
                    prefixIcon: Icon(
                      widget.icon,
                      color: const Color(0xFF5C4030),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: borderUse,
                        width: hasError ? 1.4 : 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: borderUse,
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
              const SizedBox(width: 10),
              AdjustButton(icon: Icons.add_rounded, onTap: widget.onIncrease),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            trimmed,
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

class AdjustButton extends StatelessWidget {
  const AdjustButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 50,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9A5A38), Color(0xFFB8774A)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3020532D),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class MainActionButton extends StatelessWidget {
  const MainActionButton({
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
    final bool enabled = onTap != null;

    if (!enabled) {
      return Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppThemeColors.softCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeColors.border(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppThemeColors.textMuted(context), size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textMuted(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: color,
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
                color: color.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppThemeColors.isDark(context) ? 0.22 : 0.06,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppThemeColors.textPrimary(context), size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class CardButton extends StatelessWidget {
  const CardButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MainActionButton(
      label: label,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}

class ServiceTargetSelector extends StatelessWidget {
  const ServiceTargetSelector({
    super.key,
    required this.selectedTarget,
    required this.onChanged,
  });

  final ServiceTarget selectedTarget;
  final ValueChanged<ServiceTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'لمن هذه الخدمة؟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _ServiceTargetChip(
                label: ServiceTarget.personal.arabicLabel,
                icon: Icons.person_rounded,
                isSelected: selectedTarget == ServiceTarget.personal,
                onTap: () => onChanged(ServiceTarget.personal),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ServiceTargetChip(
                label: ServiceTarget.child.arabicLabel,
                icon: Icons.child_care_rounded,
                isSelected: selectedTarget == ServiceTarget.child,
                onTap: () => onChanged(ServiceTarget.child),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ServiceTargetChip(
                label: ServiceTarget.elderly.arabicLabel,
                icon: Icons.elderly_rounded,
                isSelected: selectedTarget == ServiceTarget.elderly,
                onTap: () => onChanged(ServiceTarget.elderly),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceTargetChip extends StatelessWidget {
  const _ServiceTargetChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = AppThemeColors.brandBrown(context);

    return Material(
      color: isSelected
          ? selectedColor.withValues(alpha: 0.14)
          : AppThemeColors.softCard(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? selectedColor
                  : AppThemeColors.border(context),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? selectedColor
                    : AppThemeColors.textSecondary(context),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? selectedColor
                      : AppThemeColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
