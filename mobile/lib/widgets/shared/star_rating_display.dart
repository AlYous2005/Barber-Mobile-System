import 'package:flutter/material.dart';
import '../../utils/app_theme_colors.dart';

class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.rating,
    required this.ratingCount,
    required this.satisfactionRate,
    this.ratingBreakdown = const {5: 18, 4: 6, 3: 2, 2: 1, 1: 0},
    this.starSize = 18,
    this.enableDetailsPopup = true,
  });

  final double rating;
  final int ratingCount;
  final int satisfactionRate;
  final Map<int, int> ratingBreakdown;
  final double starSize;
  final bool enableDetailsPopup;

  double get _safeRating => rating.clamp(0, 5).toDouble();

  List<Widget> _buildStars({
    double? size,
    Color color = const Color(0xFFEAB308),
  }) {
    final double effectiveSize = size ?? starSize;

    return List.generate(5, (index) {
      final int starPosition = index + 1;
      late final IconData icon;

      if (_safeRating >= starPosition) {
        icon = Icons.star_rounded;
      } else if (_safeRating >= starPosition - 0.5) {
        icon = Icons.star_half_rounded;
      } else {
        icon = Icons.star_border_rounded;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: Icon(icon, size: effectiveSize, color: color),
      );
    });
  }

  void _showRatingDetails(BuildContext context) {
    final bool isDark = AppThemeColors.isDark(context);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            decoration: BoxDecoration(
              color: AppThemeColors.card(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppThemeColors.border(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.20),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppThemeColors.border(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: isDark
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFFFFFBEB),
                              Color(0xFFFFF7ED),
                              Color(0xFFFFFFFF),
                            ],
                          ),
                    color: isDark ? AppThemeColors.elevatedCard(context) : null,
                    border: Border.all(
                      color: isDark
                          ? AppThemeColors.border(context)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'تقييم الحلاق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _safeRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFFF6D38B)
                              : const Color(0xFF92400E),
                          height: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: TextDirection.ltr,
                        children: _buildStars(size: 28),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '$ratingCount تقييم • نسبة رضا $satisfactionRate%',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppThemeColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'تفصيل التقييمات',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ...[5, 4, 3, 2, 1].map((stars) {
                  final int count = ratingBreakdown[stars] ?? 0;
                  final double percentage = ratingCount == 0
                      ? 0
                      : count / ratingCount;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RatingBreakdownRow(
                      stars: stars,
                      count: count,
                      percentage: percentage,
                      isDark: isDark,
                    ),
                  );
                }),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppThemeColors.softCard(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppThemeColors.border(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF16A34A),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'هذه التقييمات تظهر فقط من زبائن أكملوا موعدًا فعليًا مع الحلاق.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFFC47A3D)
                          : const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'تم',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enableDetailsPopup ? () => _showRatingDetails(context) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x12F59E0B),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x30F59E0B)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12F59E0B),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: _buildStars(),
          ),
        ),
      ),
    );
  }
}

class _RatingBreakdownRow extends StatelessWidget {
  const _RatingBreakdownRow({
    required this.stars,
    required this.count,
    required this.percentage,
    required this.isDark,
  });

  final int stars;
  final bool isDark;
  final int count;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFEAB308),
                size: 17,
              ),
              const SizedBox(width: 3),
              Text(
                '$stars',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percentage.clamp(0, 1),
              minHeight: 9,
              backgroundColor: isDark
                  ? AppThemeColors.softCard(context)
                  : const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF59E0B),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 34,
          child: Text(
            '$count',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }
}
