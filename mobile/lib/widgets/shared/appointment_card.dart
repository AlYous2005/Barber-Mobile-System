import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.titleName,
    required this.serviceName,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    this.customerImage,
    this.onMarkCompleted,
    this.onCancel,
    this.showRateButton = false,
    this.onRate,
  });

  final String titleName;
  final String serviceName;
  final String dateLabel;
  final String timeLabel;
  final String status;

  /// لاحقًا لما نضيف صورة للزبون من صفحة الزبون،
  /// سنمرر الصورة هنا بدل الأيقونة الافتراضية.
  final ImageProvider? customerImage;

  final VoidCallback? onMarkCompleted;
  final VoidCallback? onCancel;

  final bool showRateButton;
  final VoidCallback? onRate;

  Color _statusColor() {
    switch (status) {
      case 'جاري':
        return const Color(0xFF2563EB);
      case 'قادم':
        return const Color(0xFF3B82F6);
      case 'معلقة':
        return const Color(0xFFF59E0B);
      case 'مؤكدة':
        return const Color(0xFF0EA5E9);
      case 'مكتمل':
      case 'مكتملة':
        return const Color(0xFF10B981);
      case 'ملغي':
      case 'ملغية':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case 'جاري':
        return Icons.play_circle_fill_rounded;
      case 'قادم':
        return Icons.schedule_rounded;
      case 'معلقة':
        return Icons.hourglass_top_rounded;
      case 'مؤكدة':
        return Icons.verified_rounded;
      case 'مكتمل':
      case 'مكتملة':
        return Icons.check_circle_rounded;
      case 'ملغي':
      case 'ملغية':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  bool get _canChangeStatus {
    return onMarkCompleted != null || onCancel != null;
  }

  bool get _hasAnyAction {
    return _canChangeStatus || (showRateButton && onRate != null);
  }

  void _openStatusActions(BuildContext context) {
    if (!_canChangeStatus) return;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
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
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'تغيير حالة الموعد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  titleName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 18),

                if (onMarkCompleted != null)
                  _SheetActionButton(
                    label: 'تعيين الموعد كمكتمل',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.of(context).pop();
                      onMarkCompleted!();
                    },
                  ),

                if (onMarkCompleted != null && onCancel != null)
                  const SizedBox(height: 10),

                if (onCancel != null)
                  _SheetActionButton(
                    label: 'إلغاء الموعد',
                    icon: Icons.cancel_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.of(context).pop();
                      onCancel!();
                    },
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'رجوع',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6B7280),
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
    final Color accentColor = _statusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          const BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white,
                      accentColor.withValues(alpha: 0.045),
                    ],
                  ),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),

            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                color: accentColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _CustomerAvatar(
                        accentColor: accentColor,
                        image: customerImage,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              serviceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      _StatusPill(
                        status: status,
                        color: accentColor,
                        icon: _statusIcon(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.calendar_month_rounded,
                            label: dateLabel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.access_time_filled_rounded,
                            label: timeLabel,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_hasAnyAction) ...[
                    const SizedBox(height: 13),

                    Row(
                      children: [
                        if (_canChangeStatus)
                          Expanded(
                            child: _ChangeStatusButton(
                              color: accentColor,
                              onTap: () => _openStatusActions(context),
                            ),
                          ),

                        if (_canChangeStatus && showRateButton && onRate != null)
                          const SizedBox(width: 10),

                        if (showRateButton && onRate != null)
                          Expanded(
                            child: _RateButton(
                              onTap: onRate!,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({
    required this.accentColor,
    required this.image,
  });

  final Color accentColor;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            accentColor.withValues(alpha: 0.42),
            accentColor.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
        ),
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFF8FAFC),
        backgroundImage: image,
        child: image == null
            ? Icon(
                Icons.person_rounded,
                color: accentColor,
                size: 28,
              )
            : null,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.status,
    required this.color,
    required this.icon,
  });

  final String status;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeStatusButton extends StatelessWidget {
  const _ChangeStatusButton({
    required this.color,
    required this.onTap,
  });

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'تغيير حالة الموعد',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
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

class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color color = Color(0xFFF59E0B);

    return Material(
      color: color.withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 17,
                color: color,
              ),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  'قيّم الحلاق',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
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

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
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
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
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