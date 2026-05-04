import 'package:flutter/material.dart';

import '../../../models/availability_models.dart';
import '../../../utils/app_theme_colors.dart';
import 'availability_shared_widgets.dart';
import 'availability_sheet_widgets.dart';

class EditClosureSheet extends StatefulWidget {
  const EditClosureSheet({
    super.key,
    required this.closure,
    required this.onSave,
  });

  final ClosureDay closure;
  final ValueChanged<ClosureDay> onSave;

  @override
  State<EditClosureSheet> createState() => _EditClosureSheetState();
}

class _EditClosureSheetState extends State<EditClosureSheet> {
  late final TextEditingController reasonController;
  late String originalDateLabel;
  late String originalReason;
  DateTime? selectedDate;
  String? dateError;
  int dateShakeTrigger = 0;

  String get currentDateLabel {
    if (selectedDate == null) return 'اختر التاريخ';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  bool get _hasChanges {
    final String normalizedCurrentReason = reasonController.text.trim().isEmpty
        ? 'بدون سبب مذكور'
        : reasonController.text.trim();
    final String normalizedOriginalReason = originalReason.trim().isEmpty
        ? 'بدون سبب مذكور'
        : originalReason.trim();

    return currentDateLabel != originalDateLabel ||
        normalizedCurrentReason != normalizedOriginalReason;
  }

  void _refreshSaveButtonState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    reasonController = TextEditingController(text: widget.closure.reason);
    originalDateLabel = widget.closure.dateLabel;
    originalReason = widget.closure.reason;
    selectedDate = _parseDateLabel(widget.closure.dateLabel);
    reasonController.addListener(_refreshSaveButtonState);
  }

  @override
  void dispose() {
    reasonController.removeListener(_refreshSaveButtonState);
    reasonController.dispose();
    super.dispose();
  }

  DateTime? _parseDateLabel(String value) {
    final List<String> parts = value.split('/');
    if (parts.length != 3) return null;

    final int? day = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate == null) return;
    setState(() {
      selectedDate = pickedDate;
      dateError = null;
    });
  }

  void _save() {
    if (selectedDate == null) {
      setState(() {
        dateError = 'يرجى اختيار تاريخ الإغلاق';
        dateShakeTrigger++;
      });
      return;
    }

    final String reason = reasonController.text.trim();

    final updatedClosure = ClosureDay(
      id: widget.closure.id,
      dateLabel: currentDateLabel,
      reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
    );
    Navigator.of(context).pop();
    widget.onSave(updatedClosure);
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
                  title: 'تعديل يوم الإغلاق',
                  subtitle: widget.closure.dateLabel,
                  icon: Icons.edit_rounded,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 18),
                AvailabilityPickerBox(
                  label: 'تاريخ الإغلاق',
                  value: currentDateLabel,
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickDate,
                  errorText: dateError,
                  hasError: dateError != null,
                  shakeTrigger: dateShakeTrigger,
                ),
                const SizedBox(height: 14),
                AvailabilityTextInputBox(
                  label: 'سبب الإغلاق',
                  hint: 'مثال: إجازة خاصة / ظرف طارئ',
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
                        onTap: _hasChanges ? _save : null,
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
