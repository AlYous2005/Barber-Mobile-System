import 'package:flutter/material.dart';

import '../../../models/barber_model.dart';
import '../../../utils/app_theme_colors.dart';

class ChooseBarberStep extends StatelessWidget {
  const ChooseBarberStep({
    super.key,
    required this.barbers,
    required this.selectedBarber,
    required this.onSelectBarber,
  });

  final List<BarberModel> barbers;
  final BarberModel? selectedBarber;
  final ValueChanged<BarberModel> onSelectBarber;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...barbers.map(
          (barber) => _WarmBarberChoiceCard(
            barber: barber,
            selected: selectedBarber?.id == barber.id,
            onTap: () => onSelectBarber(barber),
          ),
        ),
      ],
    );
  }
}

class _WarmBarberChoiceCard extends StatelessWidget {
  const _WarmBarberChoiceCard({
    required this.barber,
    required this.selected,
    required this.onTap,
  });

  final BarberModel barber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? const Color(0xFFC47A3D)
        : AppThemeColors.border(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: selected ? 1.7 : 1),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x22C47A3D)
                      : const Color(0x10000000),
                  blurRadius: selected ? 22 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                        ),
                        border: Border.all(
                          color: const Color(0xFFE7B679),
                          width: 2.4,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                    if (selected)
                      Positioned(
                        left: -2,
                        bottom: -2,
                        child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF16A34A),
                            border: Border.all(
                              color: AppThemeColors.card(context),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barber.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppThemeColors.textPrimary(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        barber.shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppThemeColors.textSecondary(context),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: AppThemeColors.textMuted(context),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'زيتا، زيتا',
                            style: TextStyle(
                              color: AppThemeColors.textSecondary(context),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _FiveStarsMiniRating(rating: barber.rating),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFC47A3D)
                        : AppThemeColors.softCard(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFC47A3D)
                          : AppThemeColors.border(context),
                    ),
                  ),
                  child: Icon(
                    selected
                        ? Icons.check_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    color: selected ? Colors.white : const Color(0xFFC47A3D),
                    size: selected ? 20 : 16,
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

class _FiveStarsMiniRating extends StatelessWidget {
  const _FiveStarsMiniRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;

        if (index < fullStars) {
          icon = Icons.star_rounded;
        } else if (index == fullStars && hasHalfStar) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Icon(icon, size: 15, color: const Color(0xFFF59E0B));
      }),
    );
  }
}
