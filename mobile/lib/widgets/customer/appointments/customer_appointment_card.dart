import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class CustomerAppointmentCard extends StatelessWidget {
  const CustomerAppointmentCard({
    super.key,
    required this.barberName,
    required this.barberRating,
    required this.serviceName,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    this.onRate,
    this.onCancel,
    this.onRebook,
  });

  final String barberName;
  final double barberRating;
  final String serviceName;
  final String dateLabel;
  final String timeLabel;
  final String status;
  final VoidCallback? onRate;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;

  bool get showRateButton => onRate != null;
  bool get showCancelButton => onCancel != null;
  bool get showRebookButton => onRebook != null;

  @override
  Widget build(BuildContext context) {
    final statusVisual = _statusFor(status);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeColors.card(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppThemeColors.border(context)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.content_cut_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحلاق $barberName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppThemeColors.textPrimary(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FiveStarsBarberRating(rating: barberRating),
                    ],
                  ),
                ),
                _StatusBadge(visual: statusVisual),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppThemeColors.softCard(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Column(
                children: [
                  _AppointmentInfoRow(
                    icon: Icons.design_services_rounded,
                    label: 'الخدمة',
                    value: serviceName,
                  ),
                  const SizedBox(height: 10),
                  _AppointmentInfoRow(
                    icon: Icons.calendar_month_rounded,
                    label: 'التاريخ',
                    value: dateLabel,
                  ),
                  const SizedBox(height: 10),
                  _AppointmentInfoRow(
                    icon: Icons.access_time_filled_rounded,
                    label: 'الوقت',
                    value: timeLabel,
                  ),
                  const SizedBox(height: 10),
                  _AppointmentInfoRow(
                    icon: Icons.info_rounded,
                    label: 'الحالة',
                    value: statusVisual.fullLabel,
                    valueColor: statusVisual.color,
                  ),
                ],
              ),
            ),
            if (showRateButton || showCancelButton || showRebookButton) ...[
              const SizedBox(height: 14),

              if (showRebookButton) ...[
                SizedBox(
                  width: double.infinity,
                  child: _AppointmentActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'إحجز مرة أخرى عند نفس الحلاق',
                    color: const Color(0xFF6E3F2F),
                    onTap: onRebook!,
                  ),
                ),
                if (showRateButton || showCancelButton)
                  const SizedBox(height: 10),
              ],

              if (showRateButton || showCancelButton)
                Row(
                  children: [
                    if (showRateButton)
                      Expanded(
                        child: _AppointmentActionButton(
                          label: 'قيّم الحلاق',
                          icon: Icons.star_rate_rounded,
                          color: const Color(0xFFC47A3D),
                          onTap: onRate!,
                        ),
                      ),

                    if (showRateButton && showCancelButton)
                      const SizedBox(width: 10),

                    if (showCancelButton)
                      Expanded(
                        child: _AppointmentActionButton(
                          label: 'إلغاء الموعد',
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFEF4444),
                          onTap: onCancel!,
                        ),
                      ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  static _AppointmentStatusVisual _statusFor(String rawStatus) {
    switch (rawStatus) {
      case 'معلق':
        return const _AppointmentStatusVisual(
          shortLabel: 'معلق',
          fullLabel: 'معلق بانتظار موافقة الحلاق',
          color: Color(0xFFF59E0B),
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
          icon: Icons.hourglass_top_rounded,
        );

      case 'قادم':
      case 'تم التأكيد':
        return const _AppointmentStatusVisual(
          shortLabel: 'تم التأكيد',
          fullLabel: 'تم التأكيد',
          color: Color(0xFF2563EB),
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
          icon: Icons.verified_rounded,
        );

      case 'مكتمل':
        return const _AppointmentStatusVisual(
          shortLabel: 'مكتمل',
          fullLabel: 'مكتمل',
          color: Color(0xFF16A34A),
          backgroundColor: Color(0xFFF0FDF4),
          borderColor: Color(0xFFBBF7D0),
          icon: Icons.check_circle_rounded,
        );
      case 'ملغي':
        return const _AppointmentStatusVisual(
          shortLabel: 'ملغي',
          fullLabel: 'تم إلغاء الموعد',
          color: Color(0xFFEF4444),
          backgroundColor: Color(0xFFFFF1F2),
          borderColor: Color(0xFFFCA5A5),
          icon: Icons.cancel_rounded,
        );
      default:
        return _AppointmentStatusVisual(
          shortLabel: rawStatus,
          fullLabel: rawStatus,
          color: const Color(0xFF6B7280),
          backgroundColor: const Color(0xFFF3F4F6),
          borderColor: const Color(0xFFE5E7EB),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _AppointmentInfoRow extends StatelessWidget {
  const _AppointmentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppThemeColors.textMuted(context)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: AppThemeColors.textSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? AppThemeColors.textPrimary(context),
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.visual});

  final _AppointmentStatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: visual.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visual.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visual.icon, size: 15, color: visual.color),
          const SizedBox(width: 6),
          Text(
            visual.shortLabel,
            style: TextStyle(
              color: visual.color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentStatusVisual {
  const _AppointmentStatusVisual({
    required this.shortLabel,
    required this.fullLabel,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });

  final String shortLabel;
  final String fullLabel;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
}

class FiveStarsBarberRating extends StatelessWidget {
  const FiveStarsBarberRating({super.key, required this.rating});

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

        return Icon(icon, size: 18, color: const Color(0xFFF59E0B));
      }),
    );
  }
}

class _AppointmentActionButton extends StatelessWidget {
  const _AppointmentActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
