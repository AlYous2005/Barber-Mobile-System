import 'package:flutter/material.dart';

import '../../../models/availability_models.dart';
import '../../../utils/app_theme_colors.dart';
import 'availability_shared_widgets.dart';

class ClosuresList extends StatelessWidget {
  const ClosuresList({
    super.key,
    required this.closures,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ClosureDay> closures;
  final ValueChanged<ClosureDay> onEdit;
  final ValueChanged<ClosureDay> onDelete;

  @override
  Widget build(BuildContext context) {
    if (closures.isEmpty) {
      return const AvailabilityEmptyState(text: 'لا توجد إغلاقات خاصة حاليًا');
    }

    return Column(
      children: closures.map((closure) {
        return ClosureCard(
          closure: closure,
          onEdit: () => onEdit(closure),
          onDelete: () => onDelete(closure),
        );
      }).toList(),
    );
  }
}

class TimeBlocksList extends StatelessWidget {
  const TimeBlocksList({
    super.key,
    required this.timeBlocks,
    required this.formatTime,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TimeBlock> timeBlocks;
  final String Function(String value) formatTime;
  final ValueChanged<TimeBlock> onEdit;
  final ValueChanged<TimeBlock> onDelete;

  @override
  Widget build(BuildContext context) {
    if (timeBlocks.isEmpty) {
      return const AvailabilityEmptyState(
        text: 'لا توجد فترات عدم توفر مسجّلة بعد',
      );
    }

    return Column(
      children: timeBlocks.map((block) {
        return TimeBlockCard(
          block: block,
          formatTime: formatTime,
          onEdit: () => onEdit(block),
          onDelete: () => onDelete(block),
        );
      }).toList(),
    );
  }
}

class ClosureCard extends StatelessWidget {
  const ClosureCard({
    super.key,
    required this.closure,
    required this.onEdit,
    required this.onDelete,
  });

  final ClosureDay closure;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AvailabilityRecordCardShell(
      icon: Icons.calendar_month_rounded,
      title: closure.dateLabel,
      subtitle: closure.reason,
      badge: 'إغلاق يوم كامل',
      badgeColor: const Color(0xFFEF4444),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class TimeBlockCard extends StatelessWidget {
  const TimeBlockCard({
    super.key,
    required this.block,
    required this.formatTime,
    required this.onEdit,
    required this.onDelete,
  });

  final TimeBlock block;
  final String Function(String value) formatTime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isRecurring = block.type == 'recurring';

    return AvailabilityRecordCardShell(
      icon: Icons.access_time_rounded,
      title: '${formatTime(block.startTime)} — ${formatTime(block.endTime)}',
      subtitle: block.reason,
      secondSubtitle: isRecurring
          ? 'يتكرر في أيام الدوام'
          : 'بتاريخ ${block.dateLabel}',
      badge: isRecurring ? 'متكرر' : 'ليوم محدد',
      badgeColor: isRecurring
          ? const Color(0xFF16A34A)
          : const Color(0xFF2563EB),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class AvailabilityRecordCardShell extends StatelessWidget {
  const AvailabilityRecordCardShell({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onEdit,
    required this.onDelete,
    this.secondSubtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? secondSubtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: badgeColor.withValues(alpha: 0.18)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppThemeColors.softCard(context),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppThemeColors.border(context)),
            ),
            child: Icon(
              icon,
              color: AppThemeColors.brandBrown(context),
              size: 21,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),

          if (secondSubtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              secondSubtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ],

          const SizedBox(height: 8),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textSecondary(context),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AvailabilityPrimaryButton(
                  label: 'تعديل',
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AvailabilityPrimaryButton(
                  label: 'حذف',
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AvailabilityEmptyState extends StatelessWidget {
  const AvailabilityEmptyState({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppThemeColors.textSecondary(context),
        ),
      ),
    );
  }
}
