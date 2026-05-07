import 'package:flutter/material.dart';

import '../../../models/selected_booking_service.dart';
import '../../../models/service_model.dart';
import '../../../models/service_target.dart';
import '../../../utils/app_theme_colors.dart';

typedef ServiceTargetToggle =
    void Function(ServiceModel service, ServiceTarget target);

enum _MainServicesTab { personal, other }

class ChooseServicesStep extends StatefulWidget {
  const ChooseServicesStep({
    super.key,
    required this.services,
    required this.selectedServices,
    required this.onToggleService,
  });

  final List<ServiceModel> services;
  final List<SelectedBookingService> selectedServices;
  final ServiceTargetToggle onToggleService;

  @override
  State<ChooseServicesStep> createState() => _ChooseServicesStepState();
}

class _ChooseServicesStepState extends State<ChooseServicesStep> {
  _MainServicesTab? activeMainTab;
  ServiceTarget activeOtherTarget = ServiceTarget.child;

  bool _isSelected(ServiceModel service, ServiceTarget target) {
    return widget.selectedServices.any((item) {
      return item.service.id == service.id && item.target == target;
    });
  }

  List<ServiceModel> get _personalServices {
    return widget.services.where(_isPersonalService).toList();
  }

  List<ServiceModel> get _childServices {
    return widget.services.where(_isChildService).toList();
  }

  List<ServiceModel> get _elderlyServices {
    return widget.services.where(_isElderlyService).toList();
  }

  bool _isPersonalService(ServiceModel service) {
    final name = service.name.trim();

    if (_containsAny(name, ['طفل', 'أطفال', 'اطفال'])) {
      return false;
    }

    return _containsAny(name, [
      'شعر',
      'لحية',
      'ماسك',
      'اسود',
      'أسود',
      'ابيض',
      'أبيض',
    ]);
  }

  bool _isChildService(ServiceModel service) {
    final name = service.name.trim();

    return _containsAny(name, [
      'طفل',
      'أطفال',
      'اطفال',
      'ماسك',
      'اسود',
      'أسود',
      'ابيض',
      'أبيض',
    ]);
  }

  bool _isElderlyService(ServiceModel service) {
    final name = service.name.trim();

    return _containsAny(name, [
      'شعر',
      'لحية',
      'ماسك',
      'اسود',
      'أسود',
      'ابيض',
      'أبيض',
      'شمع',
    ]);
  }

  bool _containsAny(String text, List<String> words) {
    final normalized = text.toLowerCase();

    return words.any((word) {
      return normalized.contains(word.toLowerCase());
    });
  }

  void _selectMainTab(_MainServicesTab tab) {
    setState(() {
      activeMainTab = tab;
    });
  }

  void _backToMainTabs() {
    setState(() {
      activeMainTab = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: activeMainTab == null
                ? _MainServicesTabs(
                    key: const ValueKey('main-tabs'),
                    onPersonalTap: () =>
                        _selectMainTab(_MainServicesTab.personal),
                    onOtherTap: () => _selectMainTab(_MainServicesTab.other),
                  )
                : _ExpandedMainTabHeader(
                    key: ValueKey('expanded-${activeMainTab!.name}'),
                    activeMainTab: activeMainTab!,
                    onBack: _backToMainTabs,
                  ),
          ),
        ),

        const SizedBox(height: 14),

        AnimatedSize(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.10),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: _buildAnimatedContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedContent() {
    if (activeMainTab == null) {
      return const _ChooseServiceTypeHint(key: ValueKey('choose-hint'));
    }

    if (activeMainTab == _MainServicesTab.personal) {
      return _PersonalServicesContent(
        key: const ValueKey('personal-content'),
        services: _personalServices,
        isSelected: _isSelected,
        onToggleService: widget.onToggleService,
      );
    }

    return _OtherServicesContent(
      key: const ValueKey('other-content'),
      activeTarget: activeOtherTarget,
      childServices: _childServices,
      elderlyServices: _elderlyServices,
      isSelected: _isSelected,
      onTargetChanged: (target) {
        setState(() {
          activeOtherTarget = target;
        });
      },
      onToggleService: widget.onToggleService,
    );
  }
}

class _MainServicesTabs extends StatelessWidget {
  const _MainServicesTabs({
    super.key,
    required this.onPersonalTap,
    required this.onOtherTap,
  });

  final VoidCallback onPersonalTap;
  final VoidCallback onOtherTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MainServicesTabButton(
            title: 'خدمات شخصية',
            subtitle: 'احجز لنفسك',
            icon: Icons.person_rounded,
            color: const Color(0xFFC47A3D),
            onTap: onPersonalTap,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _MainServicesTabButton(
            title: 'خدمات لأشخاص آخرين',
            subtitle: 'طفل أو كبير سن',
            icon: Icons.groups_rounded,
            color: const Color(0xFF2563EB),
            onTap: onOtherTap,
          ),
        ),
      ],
    );
  }
}

class _MainServicesTabButton extends StatelessWidget {
  const _MainServicesTabButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppThemeColors.isDark(context);

    return Material(
      color: dark ? AppThemeColors.elevatedCard(context) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color.withValues(alpha: 0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 23),
              ),

              const SizedBox(height: 9),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 13.5,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandedMainTabHeader extends StatelessWidget {
  const _ExpandedMainTabHeader({
    super.key,
    required this.activeMainTab,
    required this.onBack,
  });

  final _MainServicesTab activeMainTab;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final bool isPersonal = activeMainTab == _MainServicesTab.personal;
    final Color color = isPersonal
        ? const Color(0xFFC47A3D)
        : const Color(0xFF2563EB);

    return Row(
      children: [
        Material(
          color: AppThemeColors.softCard(context),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppThemeColors.textPrimary(context),
                size: 21,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 74),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  color == const Color(0xFFC47A3D)
                      ? const Color(0xFF6E3F2F)
                      : const Color(0xFF1E3A8A),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isPersonal ? Icons.person_rounded : Icons.groups_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPersonal ? 'خدمات شخصية' : 'خدمات لأشخاص آخرين',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        isPersonal
                            ? 'الخدمات التي تريد حجزها لنفسك'
                            : 'اختر هل الحجز لطفل أو لرجل كبير في السن',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChooseServiceTypeHint extends StatelessWidget {
  const _ChooseServiceTypeHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.touch_app_rounded,
            color: Color(0xFFC47A3D),
            size: 23,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'اختر نوع الخدمات أولًا، ثم ستظهر الخدمات المناسبة لك.',
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalServicesContent extends StatelessWidget {
  const _PersonalServicesContent({
    super.key,
    required this.services,
    required this.isSelected,
    required this.onToggleService,
  });

  final List<ServiceModel> services;
  final bool Function(ServiceModel service, ServiceTarget target) isSelected;
  final ServiceTargetToggle onToggleService;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const _EmptyServicesCard(
        message: 'لا توجد خدمات شخصية متاحة حاليًا',
      );
    }

    return Column(
      children: services.map((service) {
        return _PremiumSelectableServiceCard(
          service: service,
          target: ServiceTarget.personal,
          selected: isSelected(service, ServiceTarget.personal),
          onTap: () {
            onToggleService(service, ServiceTarget.personal);
          },
        );
      }).toList(),
    );
  }
}

class _OtherServicesContent extends StatelessWidget {
  const _OtherServicesContent({
    super.key,
    required this.activeTarget,
    required this.childServices,
    required this.elderlyServices,
    required this.isSelected,
    required this.onTargetChanged,
    required this.onToggleService,
  });

  final ServiceTarget activeTarget;
  final List<ServiceModel> childServices;
  final List<ServiceModel> elderlyServices;
  final bool Function(ServiceModel service, ServiceTarget target) isSelected;
  final ValueChanged<ServiceTarget> onTargetChanged;
  final ServiceTargetToggle onToggleService;

  @override
  Widget build(BuildContext context) {
    final services = activeTarget == ServiceTarget.child
        ? childServices
        : elderlyServices;

    return Column(
      children: [
        _OtherServicesTabs(
          activeTarget: activeTarget,
          onChanged: onTargetChanged,
        ),

        const SizedBox(height: 12),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: services.isEmpty
              ? _EmptyServicesCard(
                  key: ValueKey('empty-${activeTarget.databaseValue}'),
                  message: activeTarget == ServiceTarget.child
                      ? 'لا توجد خدمات أطفال متاحة حاليًا'
                      : 'لا توجد خدمات لكبار السن متاحة حاليًا',
                )
              : Column(
                  key: ValueKey('services-${activeTarget.databaseValue}'),
                  children: services.map((service) {
                    return _PremiumSelectableServiceCard(
                      service: service,
                      target: activeTarget,
                      selected: isSelected(service, activeTarget),
                      onTap: () {
                        onToggleService(service, activeTarget);
                      },
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _OtherServicesTabs extends StatelessWidget {
  const _OtherServicesTabs({
    required this.activeTarget,
    required this.onChanged,
  });

  final ServiceTarget activeTarget;
  final ValueChanged<ServiceTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OtherServicesTabButton(
              label: 'احجز لطفلك',
              icon: Icons.child_care_rounded,
              selected: activeTarget == ServiceTarget.child,
              onTap: () => onChanged(ServiceTarget.child),
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: _OtherServicesTabButton(
              label: 'احجز لرجل كبير',
              icon: Icons.elderly_rounded,
              selected: activeTarget == ServiceTarget.elderly,
              onTap: () => onChanged(ServiceTarget.elderly),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherServicesTabButton extends StatelessWidget {
  const _OtherServicesTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFC47A3D) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? Colors.white
                      : AppThemeColors.textSecondary(context),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppThemeColors.textPrimary(context),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
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

class _PremiumSelectableServiceCard extends StatelessWidget {
  const _PremiumSelectableServiceCard({
    required this.service,
    required this.target,
    required this.selected,
    required this.onTap,
  });

  final ServiceModel service;
  final ServiceTarget target;
  final bool selected;
  final VoidCallback onTap;

  bool get isZeroDuration => service.durationMinutes == 0;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool compact = screenSize.width < 380 || screenSize.height < 740;
    final bool dark = AppThemeColors.isDark(context);

    final Color cardColor = selected
        ? (dark ? const Color(0xFF2B1A12) : const Color(0xFFFFF3E8))
        : AppThemeColors.card(context);

    final Color borderColor = selected
        ? const Color(0xFFC47A3D)
        : AppThemeColors.border(context);

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 10 : 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 20 : 24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.all(compact ? 12 : 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(compact ? 20 : 24),
              border: Border.all(color: borderColor, width: selected ? 1.7 : 1),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x2BC47A3D)
                      : Colors.black.withValues(alpha: 0.055),
                  blurRadius: selected ? 20 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _ServiceIconBox(
                  serviceName: service.name,
                  target: target,
                  selected: selected,
                  compact: compact,
                ),

                SizedBox(width: compact ? 10 : 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFFC47A3D)
                                    : AppThemeColors.textPrimary(context),
                                fontSize: compact ? 15.5 : 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          _TargetBadge(target: target),
                        ],
                      ),

                      SizedBox(height: compact ? 7 : 8),

                      Row(
                        children: [
                          _MetaItem(
                            icon: Icons.access_time_rounded,
                            text: isZeroDuration
                                ? 'لا يزيد مدة الحجز'
                                : '${service.durationMinutes} دقيقة',
                            color: selected
                                ? const Color(0xFFC47A3D)
                                : AppThemeColors.textSecondary(context),
                            compact: compact,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              '${service.price} شيكل',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF16A34A),
                                fontSize: compact ? 13.5 : 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: compact ? 9 : 11),

                _SelectionCircle(selected: selected, compact: compact),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  const _TargetBadge({required this.target});

  final ServiceTarget target;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (target) {
      case ServiceTarget.personal:
        color = const Color(0xFFC47A3D);
        icon = Icons.person_rounded;
        break;
      case ServiceTarget.child:
        color = const Color(0xFF2563EB);
        icon = Icons.child_care_rounded;
        break;
      case ServiceTarget.elderly:
        color = const Color(0xFF16A34A);
        icon = Icons.elderly_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            target.arabicLabel,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceIconBox extends StatelessWidget {
  const _ServiceIconBox({
    required this.serviceName,
    required this.target,
    required this.selected,
    required this.compact,
  });

  final String serviceName;
  final ServiceTarget target;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final IconData icon = _resolveServiceIcon(serviceName, target);

    return Container(
      width: compact ? 46 : 54,
      height: compact ? 46 : 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: selected
              ? const [Color(0xFF6E3F2F), Color(0xFFC47A3D)]
              : const [Color(0xFFFFEFE4), Color(0xFFFFF8F2)],
        ),
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        border: Border.all(
          color: const Color(
            0xFFC47A3D,
          ).withValues(alpha: selected ? 0.55 : 0.20),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Icon(
        icon,
        color: selected ? Colors.white : const Color(0xFF3A2014),
        size: compact ? 23 : 27,
      ),
    );
  }

  IconData _resolveServiceIcon(String serviceName, ServiceTarget target) {
    final name = serviceName.toLowerCase();

    if (target == ServiceTarget.child) {
      return Icons.child_care_rounded;
    }

    if (target == ServiceTarget.elderly) {
      return Icons.elderly_rounded;
    }

    if (name.contains('لحية')) {
      return Icons.face_6_rounded;
    }

    if (name.contains('ماسك') || name.contains('بشرة')) {
      return Icons.spa_rounded;
    }

    if (name.contains('بكج') || name.contains('كامل')) {
      return Icons.workspace_premium_rounded;
    }

    if (name.contains('غسيل')) {
      return Icons.water_drop_rounded;
    }

    if (name.contains('شمع')) {
      return Icons.auto_fix_high_rounded;
    }

    return Icons.content_cut_rounded;
  }
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.selected, required this.compact});

  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 34 : 39;

    if (selected) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFC47A3D),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.28),
              blurRadius: 13,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 23),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeColors.border(context), width: 1.6),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.text,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: compact ? 15 : 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: compact ? 11.5 : 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyServicesCard extends StatelessWidget {
  const _EmptyServicesCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.elevatedCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFC47A3D),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
