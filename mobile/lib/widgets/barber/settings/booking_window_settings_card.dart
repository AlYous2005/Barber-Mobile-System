import 'package:flutter/material.dart';

import '../../../features/bookings/utils/booking_window_helper.dart';
import '../../../general_utils/app_theme_colors.dart';
import 'settings_shared_widgets.dart';

class BookingWindowSettingsCard extends StatelessWidget {
  const BookingWindowSettingsCard({
    super.key,
    required this.enabled,
    required this.type,
    required this.isSaving,
    required this.onToggleEnabled,
    required this.onSelectType,
  });

  final bool enabled;
  final BookingWindowType type;
  final bool isSaving;
  final ValueChanged<bool> onToggleEnabled;
  final ValueChanged<BookingWindowType> onSelectType;

  static const Color _onColor = Color(0xFF16A34A);
  static const Color _offColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final Color statusColor = enabled ? _onColor : _offColor;

    return SettingsCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SettingsIconBox(
                icon: Icons.date_range_rounded,
                color: Color(0xFFC47A3D),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحديد مدة الحجز للزبائن',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'حدد إلى أي تاريخ يستطيع الزبائن حجز المواعيد من صفحاتهم',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatusPill(
                  label: enabled
                      ? 'تقييد مدة الحجز مفعّل'
                      : 'تقييد مدة الحجز متوقف (سلوك افتراضي واسع)',
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: enabled,
                activeThumbColor: _onColor,
                onChanged: isSaving ? null : (v) => onToggleEnabled(v),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 18),
            Text(
              'نطاق التواريخ للزبون',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 10),
            _TypeOptionTile(
              title: 'اليوم فقط',
              selected: type == BookingWindowType.today,
              onTap: isSaving
                  ? null
                  : () => onSelectType(BookingWindowType.today),
            ),
            const SizedBox(height: 8),
            _TypeOptionTile(
              title: 'اليوم وغدًا',
              selected: type == BookingWindowType.todayTomorrow,
              onTap: isSaving
                  ? null
                  : () => onSelectType(BookingWindowType.todayTomorrow),
            ),
            const SizedBox(height: 8),
            _TypeOptionTile(
              title: 'أسبوع (٧ أيام من اليوم)',
              selected: type == BookingWindowType.week,
              onTap: isSaving
                  ? null
                  : () => onSelectType(BookingWindowType.week),
            ),
            const SizedBox(height: 8),
            _TypeOptionTile(
              title: 'شهر (حتى نهاية الشهر التالي)',
              selected: type == BookingWindowType.month,
              onTap: isSaving
                  ? null
                  : () => onSelectType(BookingWindowType.month),
            ),
          ],
          if (isSaving) ...[
            const SizedBox(height: 14),
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeOptionTile extends StatelessWidget {
  const _TypeOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.softCard(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? const Color(0xFFC47A3D)
                    : AppThemeColors.textMuted(context),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.textPrimary(context),
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
