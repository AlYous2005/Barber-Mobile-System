import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import '../../../utils/booking_formatters.dart';

class ServicesLiveCounter extends StatelessWidget {
  const ServicesLiveCounter({
    super.key,
    required this.totalPrice,
    required this.totalDuration,
    required this.selectedCount,
  });

  final int totalPrice;
  final int totalDuration;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedCount > 0;
    final bool dark = AppThemeColors.isDark(context);
    final List<Color> gradientColors = dark
        ? (hasSelection
              ? [
                  AppThemeColors.elevatedCard(context),
                  AppThemeColors.card(context),
                  AppThemeColors.softCard(context),
                ]
              : [
                  AppThemeColors.card(context),
                  AppThemeColors.elevatedCard(context),
                ])
        : (hasSelection
              ? const [Color(0xFFFFFFFF), Color(0xFFFFFBF7), Color(0xFFFFEDD5)]
              : const [Color(0xFFFFFFFF), Color(0xFFFFFBF7)]);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasSelection
              ? const Color(0xFFC47A3D)
              : AppThemeColors.border(context),
          width: hasSelection ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasSelection
                ? const Color(0x24C47A3D)
                : const Color(0x10000000),
            blurRadius: hasSelection ? 22 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: hasSelection
                      ? const [
                          BoxShadow(
                            color: Color(0x33C47A3D),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ]
                      : [],
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        hasSelection
                            ? 'تم اختيار $selectedCount خدمات'
                            : 'اختر خدماتك وسيظهر الحساب هنا',
                        key: ValueKey('selected-count-$selectedCount'),
                        style: TextStyle(
                          color: AppThemeColors.textPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'يتم تحديث السعر والمدة تلقائيًا',
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
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _AnimatedSummaryBox(
                  label: 'حسابك بالشيكل',
                  value: '$totalPrice ₪',
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF16A34A),
                  valueKeyText: 'price-$totalPrice',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _AnimatedSummaryBox(
                  label: 'المدة',
                  value: formatBookingDuration(totalDuration),
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFF2563EB),
                  valueKeyText: 'duration-$totalDuration',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedSummaryBox extends StatelessWidget {
  const _AnimatedSummaryBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.valueKeyText,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String valueKeyText;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$label:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              );

              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: curvedAnimation, child: child),
              );
            },
            child: Text(
              value,
              key: ValueKey(valueKeyText),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 18,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
