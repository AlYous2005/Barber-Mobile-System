import 'package:flutter/material.dart';

import '../../../models/service_model.dart';
import '../../../utils/app_theme_colors.dart';

class ChooseServicesStep extends StatelessWidget {
  const ChooseServicesStep({
    super.key,
    required this.services,
    required this.selectedServices,
    required this.onToggleService,
  });

  final List<ServiceModel> services;
  final List<ServiceModel> selectedServices;
  final ValueChanged<ServiceModel> onToggleService;

  bool _isSelected(ServiceModel service) {
    return selectedServices.any((item) => item.id == service.id);
  }

  @override
  Widget build(BuildContext context) {
    final regularServices = services
        .where((service) => service.id != 'child_haircut')
        .toList();

    final childServices = services
        .where((service) => service.id == 'child_haircut')
        .toList();

    return Column(
      children: [
        const _ServicesSectionTitle(
          title: 'الخدمات المتوفرة',
          subtitle: 'اختر خدمة واحدة أو أكثر حسب ما تحتاجه.',
          icon: Icons.content_cut_rounded,
        ),

        const SizedBox(height: 12),

        ...regularServices.map(
          (service) => _SelectableServiceCard(
            service: service,
            selected: _isSelected(service),
            onTap: () => onToggleService(service),
          ),
        ),

        if (childServices.isNotEmpty) ...[
          const SizedBox(height: 10),

          const _ChildServiceInfoCard(),

          const SizedBox(height: 12),

          ...childServices.map(
            (service) => _SelectableServiceCard(
              service: service,
              selected: _isSelected(service),
              onTap: () => onToggleService(service),
            ),
          ),
        ],
      ],
    );
  }
}

class _ServicesSectionTitle extends StatelessWidget {
  const _ServicesSectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFC47A3D), size: 20),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableServiceCard extends StatelessWidget {
  const _SelectableServiceCard({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final ServiceModel service;
  final bool selected;
  final VoidCallback onTap;

  bool get isZeroDuration => service.durationMinutes == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? const Color(0xFFC47A3D)
                    : AppThemeColors.border(context),
                width: selected ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x22C47A3D)
                      : const Color(0x0D000000),
                  blurRadius: selected ? 20 : 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFC47A3D)
                        : AppThemeColors.softCard(context),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFC47A3D)
                          : AppThemeColors.border(context),
                    ),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_rounded,
                    color: selected ? Colors.white : const Color(0xFFC47A3D),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          color: AppThemeColors.textPrimary(context),
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _ServiceMiniBadge(
                            icon: Icons.payments_rounded,
                            text: '${service.price} شيكل',
                            color: const Color(0xFF16A34A),
                          ),
                          _ServiceMiniBadge(
                            icon: Icons.access_time_rounded,
                            text: isZeroDuration
                                ? 'لا يزيد مدة الحجز'
                                : '${service.durationMinutes} دقيقة',
                            color: isZeroDuration
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF2563EB),
                          ),
                        ],
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
  }
}

class _ServiceMiniBadge extends StatelessWidget {
  const _ServiceMiniBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildServiceInfoCard extends StatelessWidget {
  const _ChildServiceInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.child_care_rounded,
            color: Color(0xFFC47A3D),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'يمكنك حجز موعد لحلاقة طفلك أيضًا عن طريق هذه الخدمة.',
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
