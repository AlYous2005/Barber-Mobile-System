import 'package:flutter/material.dart';

import '../../../models/working_day_model.dart';
import '../../../utils/app_theme_colors.dart';
import 'working_hours_edit_sheet_widgets.dart';

class WorkingHoursEditSheet extends StatefulWidget {
  const WorkingHoursEditSheet({
    super.key,
    required this.day,
    required this.onSave,
  });

  final WorkingDay day;
  final ValueChanged<WorkingDay> onSave;

  @override
  State<WorkingHoursEditSheet> createState() => _WorkingHoursEditSheetState();
}

class _WorkingHoursEditSheetState extends State<WorkingHoursEditSheet> {
  late String editStartTime;
  late String editEndTime;
  late bool editIsActive;

  @override
  void initState() {
    super.initState();

    editStartTime = widget.day.startTime;
    editEndTime = widget.day.endTime;
    editIsActive = widget.day.isActive;
  }

  void _saveChanges() {
    final updatedDay = widget.day.copyWith(
      startTime: editStartTime,
      endTime: editEndTime,
      isActive: editIsActive,
    );

    widget.onSave(updatedDay);
    Navigator.of(context).pop();
  }

  static Future<String?> _pickTime({
    required BuildContext context,
    required String initialValue,
  }) async {
    final parts = initialValue.split(':');
    final hour = int.tryParse(parts.first) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (picked == null) return null;

    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: AppThemeColors.card(context),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
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

                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(
                            0xFFC47A3D,
                          ).withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_calendar_rounded,
                        color: Color(0xFFC47A3D),
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تعديل ساعات العمل',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.day.dayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Material(
                      color: AppThemeColors.softCard(context),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.close_rounded,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppThemeColors.softCard(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppThemeColors.border(context)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حالة اليوم',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppThemeColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              editIsActive
                                  ? 'هذا اليوم مفتوح للحجوزات'
                                  : 'هذا اليوم مغلق ولن تظهر فيه حجوزات',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Switch(
                        value: editIsActive,
                        activeThumbColor: const Color(0xFF16A34A),
                        onChanged: (value) {
                          setState(() {
                            editIsActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                if (editIsActive) ...[
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TimePickerBox(
                          label: 'وقت البداية',
                          value: editStartTime,
                          onTap: () async {
                            final picked = await _pickTime(
                              context: context,
                              initialValue: editStartTime,
                            );

                            if (picked == null) return;

                            setState(() {
                              editStartTime = picked;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TimePickerBox(
                          label: 'وقت النهاية',
                          value: editEndTime,
                          onTap: () async {
                            final picked = await _pickTime(
                              context: context,
                              initialValue: editEndTime,
                            );

                            if (picked == null) return;

                            setState(() {
                              editEndTime = picked;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.timer_off_rounded,
                          color: Color(0xFFB91C1C),
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'عند حفظ التعديلات سيتم اعتبار هذا اليوم مغلقًا بالكامل.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryActionButton(
                        label: 'حفظ التعديلات',
                        icon: Icons.save_rounded,
                        onTap: _saveChanges,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SecondaryActionButton(
                        label: 'إلغاء',
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
