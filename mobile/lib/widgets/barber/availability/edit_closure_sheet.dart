import 'package:flutter/material.dart';

import '../../../models/availability_models.dart';
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

  @override
  void initState() {
    super.initState();
    reasonController = TextEditingController(text: widget.closure.reason);
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  void _save() {
    final String reason = reasonController.text.trim();

    final updatedClosure = widget.closure.copyWith(
      reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
    );

    widget.onSave(updatedClosure);
    Navigator.of(context).pop();
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
            color: Colors.white,
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
                        onTap: _save,
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