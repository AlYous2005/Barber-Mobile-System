import 'package:flutter/material.dart';

import '../../general_utils/app_theme_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  final String title;
  final String value;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  IconData _resolveIcon() {
    if (title.contains('معلقة')) {
      return Icons.hourglass_top_rounded;
    }

    if (title.contains('مؤكدة')) {
      return Icons.verified_rounded;
    }

    if (title.contains('مكتملة')) {
      return Icons.check_circle_rounded;
    }

    if (title.contains('ملغية')) {
      return Icons.cancel_rounded;
    }

    return Icons.insert_chart_rounded;
  }

  String _resolveSubtitle() {
    if (title.contains('معلقة')) {
      return 'بانتظار الموافقة';
    }

    if (title.contains('مؤكدة')) {
      return 'جاهزة للتنفيذ';
    }

    if (title.contains('مكتملة')) {
      return 'تم إنجازها';
    }

    if (title.contains('ملغية')) {
      return 'تم إلغاؤها';
    }

    return 'إحصائية اليوم';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppThemeColors.isDark(context);
    final Color readableTextColor = isDark
        ? const Color(0xFFF8F3ED)
        : const Color(0xFF1F2937);
    final Color chipBackgroundColor = isDark
        ? Colors.white.withValues(alpha: 0.82)
        : Colors.white.withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isSelected
                ? color.withValues(alpha: 0.17)
                : color.withValues(alpha: 0.09),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.65)
                  : color.withValues(alpha: 0.22),
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withValues(alpha: 0.24)
                    : color.withValues(alpha: 0.10),
                blurRadius: isSelected ? 22 : 16,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: isDark ? 0.24 : 0.16),
                  ),
                  child: Center(
                    child: _StatIcon(
                      icon: _resolveIcon(),
                      color: color,
                      shouldAnimate: title.contains('معلقة'),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.topLeft,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isSelected ? 1 : 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: readableTextColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: color,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chipBackgroundColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: color.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        _resolveSubtitle(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: color.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatIcon extends StatefulWidget {
  const _StatIcon({
    required this.icon,
    required this.color,
    required this.shouldAnimate,
  });

  final IconData icon;
  final Color color;
  final bool shouldAnimate;

  @override
  State<_StatIcon> createState() => _StatIconState();
}

class _StatIconState extends State<_StatIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.shouldAnimate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _StatIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    }

    if (!widget.shouldAnimate && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldAnimate) {
      return Icon(widget.icon, size: 18, color: widget.color);
    }

    return RotationTransition(
      turns: _rotationAnimation,
      child: Icon(widget.icon, size: 18, color: widget.color),
    );
  }
}
