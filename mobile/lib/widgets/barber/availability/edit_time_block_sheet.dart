import 'package:flutter/material.dart';

import '../../../features/barber/schedule/schedule.dart';
import '../../../general_utils/app_theme_colors.dart';
import '../../shared/app_date_picker_sheet.dart';
import 'availability_shared_widgets.dart';
import 'availability_sheet_widgets.dart';

class EditTimeBlockSheet extends StatefulWidget {
  const EditTimeBlockSheet({
    super.key,
    required this.block,
    required this.onSave,
  });

  final TimeBlock block;
  final ValueChanged<TimeBlock> onSave;

  @override
  State<EditTimeBlockSheet> createState() => _EditTimeBlockSheetState();
}

class _EditTimeBlockSheetState extends State<EditTimeBlockSheet> {
  late String editType;
  DateTime? editDate;
  late String editStart;
  late String editEnd;
  late final TextEditingController reasonController;
  String? dateError;
  String? startTimeError;
  String? endTimeError;
  int dateShakeTrigger = 0;
  int startTimeShakeTrigger = 0;
  int endTimeShakeTrigger = 0;

  @override
  void initState() {
    super.initState();

    editType = widget.block.type;
    editStart = widget.block.startTime;
    editEnd = widget.block.endTime;
    reasonController = TextEditingController(text: widget.block.reason);
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickEditDate() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime maxDate = today.add(const Duration(days: 365));

    final DateTime? pickedDate = await showAppDatePickerSheet(
      context: context,
      initialDate: editDate ?? today,
      title: 'تاريخ فترة عدم التوفر',
      subtitle: 'اختر الشهر واليوم بالسحب',
      minSelectableDate: today,
      maxSelectableDate: maxDate,
    );

    if (pickedDate == null) return;

    setState(() {
      editDate = pickedDate;
      dateError = null;
    });
  }

  Future<void> _pickEditStart() async {
    final picked = await _pickTime(context: context, initialValue: editStart);

    if (picked == null) return;

    setState(() {
      editStart = picked;
      startTimeError = null;
    });
  }

  Future<void> _pickEditEnd() async {
    final picked = await _pickTime(context: context, initialValue: editEnd);

    if (picked == null) return;

    setState(() {
      editEnd = picked;
      endTimeError = null;
    });
  }

  void _saveEdit() {
    setState(() {
      dateError = null;
      startTimeError = null;
      endTimeError = null;
    });

    if (editType == 'specific' &&
        editDate == null &&
        widget.block.dateLabel == null) {
      setState(() {
        dateError = 'يرجى اختيار تاريخ فترة عدم التوفر';
        dateShakeTrigger++;
      });
      return;
    }

    if (editStart.trim().isEmpty) {
      setState(() {
        startTimeError = 'يرجى اختيار وقت البداية';
        startTimeShakeTrigger++;
      });
      return;
    }

    if (editEnd.trim().isEmpty) {
      setState(() {
        endTimeError = 'يرجى اختيار وقت النهاية';
        endTimeShakeTrigger++;
      });
      return;
    }

    if (!_isStartBeforeEnd(editStart, editEnd)) {
      setState(() {
        endTimeError = 'وقت البداية يجب أن يكون قبل وقت النهاية';
        startTimeShakeTrigger++;
        endTimeShakeTrigger++;
      });
      return;
    }

    final String reason = reasonController.text.trim();

    final updatedBlock = widget.block.copyWith(
      type: editType,
      dateLabel: editType == 'specific'
          ? (editDate == null ? widget.block.dateLabel : _dateLabel(editDate))
          : null,
      startTime: editStart,
      endTime: editEnd,
      reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
    );

    widget.onSave(updatedBlock);
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

  String _dateLabel(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _formatTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final time = TimeOfDay(hour: hour, minute: minute);
    final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final displayMinute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

    return '$displayHour:$displayMinute $period';
  }

  bool _isStartBeforeEnd(String start, String end) {
    final List<String> startParts = start.split(':');
    final List<String> endParts = end.split(':');
    final int startMinutes =
        ((int.tryParse(startParts[0]) ?? 0) * 60) +
        (startParts.length > 1 ? int.tryParse(startParts[1]) ?? 0 : 0);
    final int endMinutes =
        ((int.tryParse(endParts[0]) ?? 0) * 60) +
        (endParts.length > 1 ? int.tryParse(endParts[1]) ?? 0 : 0);
    return startMinutes < endMinutes;
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
                const AvailabilitySheetHandle(),
                const SizedBox(height: 16),
                AvailabilitySheetHeader(
                  title: 'تعديل فترة عدم التوفر',
                  subtitle: editType == 'recurring'
                      ? 'تتكرر في أيام الدوام'
                      : 'ليوم محدد',
                  icon: Icons.edit_rounded,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 18),
                AvailabilityModeSwitch(
                  selectedMode: editType,
                  onChanged: (value) {
                    setState(() {
                      editType = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                if (editType == 'specific')
                  AvailabilityPickerBox(
                    label: 'التاريخ',
                    value: editDate == null
                        ? (widget.block.dateLabel ?? 'اختر التاريخ')
                        : _dateLabel(editDate),
                    icon: Icons.calendar_month_rounded,
                    onTap: _pickEditDate,
                    errorText: dateError,
                    hasError: dateError != null,
                    shakeTrigger: dateShakeTrigger,
                  )
                else
                  const AvailabilityInfoBox(
                    text:
                        'هذه الفترة ستتكرر تلقائيًا على كل يوم مفعّل في ساعات العمل.',
                    icon: Icons.repeat_rounded,
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AvailabilityPickerBox(
                        label: 'من الساعة',
                        value: _formatTime(editStart),
                        icon: Icons.access_time_rounded,
                        onTap: _pickEditStart,
                        errorText: startTimeError,
                        hasError: startTimeError != null,
                        shakeTrigger: startTimeShakeTrigger,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AvailabilityPickerBox(
                        label: 'إلى الساعة',
                        value: _formatTime(editEnd),
                        icon: Icons.access_time_rounded,
                        onTap: _pickEditEnd,
                        errorText: endTimeError,
                        hasError: endTimeError != null,
                        shakeTrigger: endTimeShakeTrigger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AvailabilityTextInputBox(
                  label: 'السبب',
                  hint: 'مثال: استراحة غداء',
                  icon: Icons.info_rounded,
                  controller: reasonController,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: AvailabilityPrimaryButton(
                        label: 'حفظ التعديلات',
                        icon: Icons.save_rounded,
                        color: const Color(0xFFC47A3D),
                        onTap: _saveEdit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AvailabilitySecondaryButton(
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
