import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../shared/service_icon_view.dart';

import '../../../features/barber/services_management/services_management.dart';
import '../../../general_utils/app_theme_colors.dart';

enum ManualAppointmentDateChoice { today, tomorrow, custom }

extension ManualAppointmentDateChoiceX on ManualAppointmentDateChoice {
  String get arabicLabel {
    switch (this) {
      case ManualAppointmentDateChoice.today:
        return 'اليوم';
      case ManualAppointmentDateChoice.tomorrow:
        return 'غدًا';
      case ManualAppointmentDateChoice.custom:
        return 'تاريخ محدد';
    }
  }

  IconData get icon {
    switch (this) {
      case ManualAppointmentDateChoice.today:
        return Icons.today_rounded;
      case ManualAppointmentDateChoice.tomorrow:
        return Icons.next_week_rounded;
      case ManualAppointmentDateChoice.custom:
        return Icons.calendar_month_rounded;
    }
  }
}

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

class ManualServicesSelector extends StatelessWidget {
  const ManualServicesSelector({
    super.key,
    required this.services,
    required this.selectedServices,
    required this.activeTarget,
    required this.onTargetChanged,
    required this.onToggleService,
    this.isLoadingServices = false,
    this.loadErrorText,
    this.errorText,
    this.hasError = false,
    this.shakeTrigger = 0,
  });

  final List<ServiceModel> services;
  final List<ServiceModel> selectedServices;
  final ServiceTarget? activeTarget;
  final ValueChanged<ServiceTarget?> onTargetChanged;
  final ValueChanged<ServiceModel> onToggleService;
  final bool isLoadingServices;
  final String? loadErrorText;
  final String? errorText;
  final bool hasError;
  final int shakeTrigger;

  List<ServiceModel> get _activeServices {
    if (activeTarget == null) {
      return [];
    }

    return services.where((service) => service.target == activeTarget).toList();
  }

  int get _totalDuration {
    return selectedServices.fold(
      0,
      (sum, service) => sum + service.durationMinutes,
    );
  }

  int get _totalPrice {
    return selectedServices.fold(0, (sum, service) => sum + service.price);
  }

  int _selectedCountForTarget(ServiceTarget target) {
    return selectedServices.where((service) => service.target == target).length;
  }

  @override
  Widget build(BuildContext context) {
    const Color errorColor = Color(0xFFEF4444);

    return ShakeOnChange(
      trigger: shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الخدمات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 9),
          _ManualServiceTargetTabs(
            activeTarget: activeTarget,
            selectedCountForTarget: _selectedCountForTarget,
            onChanged: onTargetChanged,
          ),
          const SizedBox(height: 12),
          if (isLoadingServices)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasError ? errorColor : AppThemeColors.border(context),
                ),
              ),
              child: Text(
                'جاري تحميل الخدمات...',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppThemeColors.textMuted(context)),
              ),
            )
          else if (services.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasError ? errorColor : AppThemeColors.border(context),
                ),
              ),
              child: Text(
                loadErrorText ?? 'لا توجد خدمات مفعّلة حاليًا',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: activeTarget == null
                  ? _ManualClosedServicesPanel(
                      key: const ValueKey('closed_services_panel'),
                    )
                  : _ManualServicesTargetList(
                      key: ValueKey(activeTarget!.databaseValue),
                      services: _activeServices,
                      selectedServices: selectedServices,
                      activeTarget: activeTarget!,
                      onToggleService: onToggleService,
                    ),
            ),
          if (selectedServices.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ManualSummaryPill(
                    icon: Icons.payments_rounded,
                    label: 'السعر',
                    value: '₪$_totalPrice',
                    color: const Color(0xFF15803D),
                    backgroundColor: const Color(0xFFEEFBF2),
                    borderColor: const Color(0xFFBBF7D0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ManualSummaryPill(
                    icon: Icons.schedule_rounded,
                    label: 'المدة',
                    value: '$_totalDuration دقيقة',
                    color: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFBFDBFE),
                  ),
                ),
              ],
            ),
          ],
          if (loadErrorText != null && services.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              loadErrorText!,
              style: const TextStyle(
                color: errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              textAlign: TextAlign.center,
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

class _ManualServiceTargetTabs extends StatelessWidget {
  const _ManualServiceTargetTabs({
    required this.activeTarget,
    required this.selectedCountForTarget,
    required this.onChanged,
  });

  final ServiceTarget? activeTarget;
  final int Function(ServiceTarget target) selectedCountForTarget;
  final ValueChanged<ServiceTarget?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ManualServiceTargetTab(
            label: ServiceTarget.personal.arabicLabel,
            icon: Icons.person_rounded,
            count: selectedCountForTarget(ServiceTarget.personal),
            isActive: activeTarget == ServiceTarget.personal,
            onTap: () => onChanged(
              activeTarget == ServiceTarget.personal
                  ? null
                  : ServiceTarget.personal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ManualServiceTargetTab(
            label: ServiceTarget.child.arabicLabel,
            icon: Icons.child_care_rounded,
            count: selectedCountForTarget(ServiceTarget.child),
            isActive: activeTarget == ServiceTarget.child,
            onTap: () => onChanged(
              activeTarget == ServiceTarget.child ? null : ServiceTarget.child,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ManualServiceTargetTab(
            label: ServiceTarget.elderly.arabicLabel,
            icon: Icons.elderly_rounded,
            count: selectedCountForTarget(ServiceTarget.elderly),
            isActive: activeTarget == ServiceTarget.elderly,
            onTap: () => onChanged(
              activeTarget == ServiceTarget.elderly
                  ? null
                  : ServiceTarget.elderly,
            ),
          ),
        ),
      ],
    );
  }
}

class _ManualServiceTargetTab extends StatelessWidget {
  const _ManualServiceTargetTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppThemeColors.brandBrown(context);

    return Material(
      color: isActive
          ? activeColor.withValues(alpha: 0.14)
          : AppThemeColors.softCard(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? activeColor : AppThemeColors.border(context),
              width: isActive ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isActive
                        ? activeColor
                        : AppThemeColors.textSecondary(context),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -8,
                      left: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: isActive
                      ? activeColor
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

class _ManualServicesTargetList extends StatelessWidget {
  const _ManualServicesTargetList({
    super.key,
    required this.services,
    required this.selectedServices,
    required this.activeTarget,
    required this.onToggleService,
  });

  final List<ServiceModel> services;
  final List<ServiceModel> selectedServices;
  final ServiceTarget activeTarget;
  final ValueChanged<ServiceModel> onToggleService;

  bool _isSelected(ServiceModel service) {
    return selectedServices.any((item) => item.id == service.id);
  }

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppThemeColors.softCard(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppThemeColors.border(context)),
        ),
        child: Text(
          'لا توجد خدمات ضمن فئة "${activeTarget.arabicLabel}"',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppThemeColors.textMuted(context),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Column(
      children: services.map((service) {
        final bool selected = _isSelected(service);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: selected
                ? AppThemeColors.brandBrown(context).withValues(alpha: 0.12)
                : AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onToggleService(service),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppThemeColors.brandBrown(context)
                        : AppThemeColors.border(context),
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    _ManualServiceVisual(service: service, selected: selected),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${service.durationMinutes} دقيقة — ₪${service.price}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ManualServiceVisual extends StatelessWidget {
  const _ManualServiceVisual({required this.service, required this.selected});

  final ServiceModel service;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = _cleanText(service.serviceImageUrl);
    final ServiceIconOption iconOption = ServiceIconOptions.byKey(
      service.serviceIconKey,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: imageUrl == null
                ? AppThemeColors.card(context)
                : AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? AppThemeColors.brandBrown(context)
                  : AppThemeColors.border(context),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl == null
                ? ServiceIconView(
                    option: iconOption,
                    size: 21,
                    fallbackColor: selected
                        ? AppThemeColors.brandBrown(context)
                        : AppThemeColors.textSecondary(context),
                    assetPadding: 2,
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        iconOption.icon,
                        color: selected
                            ? AppThemeColors.brandBrown(context)
                            : AppThemeColors.textSecondary(context),
                        size: 21,
                      );
                    },
                  ),
          ),
        ),

        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: selected
                  ? AppThemeColors.brandBrown(context)
                  : AppThemeColors.card(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppThemeColors.border(context)),
            ),
            child: Icon(
              selected
                  ? Icons.check_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? Colors.white
                  : AppThemeColors.textMuted(context),
              size: selected ? 13 : 12,
            ),
          ),
        ),
      ],
    );
  }
}

String? _cleanText(String? value) {
  if (value == null) {
    return null;
  }

  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  return trimmed;
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

class _ManualClosedServicesPanel extends StatelessWidget {
  const _ManualClosedServicesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Text(
        'اختر تبويبة لعرض الخدمات',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppThemeColors.textMuted(context),
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ManualSummaryPill extends StatelessWidget {
  const _ManualSummaryPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label: $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ManualDateChoiceSelector extends StatelessWidget {
  const ManualDateChoiceSelector({
    super.key,
    required this.selectedChoice,
    required this.customDate,
    required this.onChoiceSelected,
    this.errorText,
    this.hasError = false,
    this.shakeTrigger = 0,
  });

  final ManualAppointmentDateChoice selectedChoice;
  final DateTime? customDate;
  final ValueChanged<ManualAppointmentDateChoice> onChoiceSelected;
  final String? errorText;
  final bool hasError;
  final int shakeTrigger;

  String _customDateLabel() {
    if (customDate == null) {
      return ManualAppointmentDateChoice.custom.arabicLabel;
    }

    return '${customDate!.day}/${customDate!.month}/${customDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    const Color errorColor = Color(0xFFEF4444);

    return ShakeOnChange(
      trigger: shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تاريخ الموعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _ManualDateChoiceChip(
                  label: ManualAppointmentDateChoice.today.arabicLabel,
                  icon: ManualAppointmentDateChoice.today.icon,
                  isSelected:
                      selectedChoice == ManualAppointmentDateChoice.today,
                  onTap: () =>
                      onChoiceSelected(ManualAppointmentDateChoice.today),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ManualDateChoiceChip(
                  label: ManualAppointmentDateChoice.tomorrow.arabicLabel,
                  icon: ManualAppointmentDateChoice.tomorrow.icon,
                  isSelected:
                      selectedChoice == ManualAppointmentDateChoice.tomorrow,
                  onTap: () =>
                      onChoiceSelected(ManualAppointmentDateChoice.tomorrow),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ManualDateChoiceChip(
                  label: _customDateLabel(),
                  icon: ManualAppointmentDateChoice.custom.icon,
                  isSelected:
                      selectedChoice == ManualAppointmentDateChoice.custom,
                  onTap: () =>
                      onChoiceSelected(ManualAppointmentDateChoice.custom),
                ),
              ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              textAlign: TextAlign.center,
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

class _ManualDateChoiceChip extends StatelessWidget {
  const _ManualDateChoiceChip({
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
                  fontSize: 11.5,
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

class ManualAvailableTimeSlotsSelector extends StatelessWidget {
  const ManualAvailableTimeSlotsSelector({
    super.key,
    required this.slots,
    required this.selectedTime,
    required this.onSelectSlot,
    this.isLoading = false,
    this.message,
    this.errorText,
    this.hasError = false,
    this.shakeTrigger = 0,
  });

  final List<DateTime> slots;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onSelectSlot;
  final bool isLoading;
  final String? message;
  final String? errorText;
  final bool hasError;
  final int shakeTrigger;

  bool _isSelected(DateTime slot) {
    if (selectedTime == null) {
      return false;
    }

    return selectedTime!.hour == slot.hour &&
        selectedTime!.minute == slot.minute;
  }

  String _formatSlot(DateTime slot) {
    final TimeOfDay time = TimeOfDay.fromDateTime(slot);
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'ص' : 'م';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    const Color errorColor = Color(0xFFEF4444);

    return ShakeOnChange(
      trigger: shakeTrigger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الأوقات المتاحة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 9),
          if (isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasError ? errorColor : AppThemeColors.border(context),
                ),
              ),
              child: Text(
                'جاري تحميل الأوقات المتاحة...',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppThemeColors.textMuted(context)),
              ),
            )
          else if (slots.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasError ? errorColor : AppThemeColors.border(context),
                ),
              ),
              child: Text(
                message ?? 'لا توجد أوقات متاحة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hasError
                      ? errorColor
                      : AppThemeColors.textMuted(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: slots.map((slot) {
                final bool selected = _isSelected(slot);

                return Material(
                  color: selected
                      ? AppThemeColors.brandBrown(
                          context,
                        ).withValues(alpha: 0.14)
                      : AppThemeColors.softCard(context),
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: () => onSelectSlot(slot),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? AppThemeColors.brandBrown(context)
                              : AppThemeColors.border(context),
                          width: selected ? 1.4 : 1,
                        ),
                      ),
                      child: Text(
                        _formatSlot(slot),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? AppThemeColors.brandBrown(context)
                              : AppThemeColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              textAlign: TextAlign.center,
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
