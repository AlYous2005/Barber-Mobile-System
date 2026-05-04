import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import '../../shared/star_rating_display.dart';

class BarberProfilePreview extends StatelessWidget {
  const BarberProfilePreview({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Ink(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFC47A3D), Color(0xFFF6D38B)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 43,
                        backgroundColor: AppThemeColors.softCard(context),
                        child: const Icon(
                          Icons.content_cut_rounded,
                          size: 38,
                          color: Color(0xFFC47A3D),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 5,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22C55E),
                            border: Border.all(
                              color: AppThemeColors.card(context),
                              width: 3,
                            ),
                            boxShadow: AppThemeColors.isDark(context)
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF22C55E,
                                      ).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          const StarRatingDisplay(
            rating: 4.8,
            ratingCount: 27,
            satisfactionRate: 96,
            starSize: 18,
            enableDetailsPopup: true,
          ),
        ],
      ),
    );
  }
}
