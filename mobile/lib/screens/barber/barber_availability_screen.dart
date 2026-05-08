// UI + date/time pickers + dialogs + sheets + popups
import 'package:flutter/material.dart';

import '../../controllers/barber/barber_availability_controller.dart';
import '../../models/availability_models.dart';
import '../../widgets/barber/availability/availability_add_cards.dart';
import '../../widgets/barber/availability/availability_confirm_dialog.dart';
import '../../widgets/barber/availability/availability_intro_card.dart';
import '../../widgets/barber/availability/availability_lists.dart';
import '../../widgets/barber/availability/availability_subnav.dart';
import '../../widgets/barber/availability/edit_closure_sheet.dart';
import '../../widgets/barber/availability/edit_time_block_sheet.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

class BarberAvailabilityScreen extends StatefulWidget {
  const BarberAvailabilityScreen({super.key});

  @override
  State<BarberAvailabilityScreen> createState() =>
      _BarberAvailabilityScreenState();
}

class _BarberAvailabilityScreenState extends State<BarberAvailabilityScreen> {
  late final BarberAvailabilityController controller;

  @override
  void initState() {
    super.initState();
    controller = BarberAvailabilityController();
    controller.loadAvailability();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickClosureDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedClosureDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate == null) return;

    controller.setClosureDate(pickedDate);
  }

  Future<void> _pickTimeBlockDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedTimeBlockDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate == null) return;

    controller.setTimeBlockDate(pickedDate);
  }

  Future<void> _pickStartTime() async {
    final String? picked = await _pickTime(
      context: context,
      initialValue: controller.selectedStartTime,
    );

    if (picked == null) return;

    controller.setStartTime(picked);
  }

  Future<void> _pickEndTime() async {
    final String? picked = await _pickTime(
      context: context,
      initialValue: controller.selectedEndTime,
    );

    if (picked == null) return;

    controller.setEndTime(picked);
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

  Future<void> _addClosure() async {
    final bool added = await controller.addClosure();

    if (!mounted || !added) return;

    await _showSuccessPopup(
      title: 'تمت إضافة يوم الإغلاق',
      message: 'تمت إضافة يوم الإغلاق بنجاح',
      icon: Icons.event_busy_rounded,
      iconStartColor: const Color(0xFF16A34A),
      iconEndColor: const Color(0xFF86EFAC),
    );
  }

  Future<void> _addTimeBlock() async {
    final bool added = await controller.addTimeBlock();

    if (!mounted || !added) return;

    await _showSuccessPopup(
      title: 'تمت إضافة فترة عدم التوفر',
      message: 'تمت إضافة فترة عدم التوفر بنجاح',
      icon: Icons.block_rounded,
      iconStartColor: const Color(0xFF16A34A),
      iconEndColor: const Color(0xFF86EFAC),
    );
  }

  void _deleteClosure(ClosureDay closure) {
    _showConfirmDialog(
      title: 'حذف يوم الإغلاق',
      message: 'هل تريد حذف يوم الإغلاق بتاريخ ${closure.dateLabel}؟',
      confirmText: 'حذف',
      color: const Color(0xFFEF4444),
      onConfirm: () async {
        await controller.deleteClosure(closure);

        if (!mounted) return;

        await _showSuccessPopup(
          title: 'تم حذف يوم الإغلاق',
          message: 'تم حذف يوم الإغلاق بنجاح',
          icon: Icons.delete_outline_rounded,
          iconStartColor: const Color(0xFFDC2626),
          iconEndColor: const Color(0xFFFCA5A5),
        );
      },
    );
  }

  void _deleteTimeBlock(TimeBlock block) {
    _showConfirmDialog(
      title: 'حذف فترة عدم التوفر',
      message:
          'هل تريد حذف الفترة من ${controller.formatTime(block.startTime)} إلى ${controller.formatTime(block.endTime)}؟',
      confirmText: 'حذف',
      color: const Color(0xFFEF4444),
      onConfirm: () async {
        await controller.deleteTimeBlock(block);

        if (!mounted) return;

        await _showSuccessPopup(
          title: 'تم حذف فترة عدم التوفر',
          message: 'تم حذف فترة عدم التوفر بنجاح',
          icon: Icons.delete_outline_rounded,
          iconStartColor: const Color(0xFFDC2626),
          iconEndColor: const Color(0xFFFCA5A5),
        );
      },
    );
  }

  void _editClosure(ClosureDay closure) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditClosureSheet(
          closure: closure,
          onSave: (updatedClosure) async {
            await controller.updateClosure(updatedClosure);

            if (!mounted) return;

            await _showSuccessPopup(
              title: 'تم تعديل يوم الإغلاق',
              message: 'تم حفظ تغييرات يوم الإغلاق بنجاح',
              icon: Icons.edit_calendar_rounded,
              iconStartColor: const Color(0xFFC47A3D),
              iconEndColor: const Color(0xFFF6D38B),
            );
          },
        );
      },
    );
  }

  void _editTimeBlock(TimeBlock block) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditTimeBlockSheet(
          block: block,
          onSave: (updatedBlock) async {
            await controller.updateTimeBlock(updatedBlock);

            if (!mounted) return;

            await _showSuccessPopup(
              title: 'تم تعديل فترة عدم التوفر',
              message: 'تم تعديل فترة عدم التوفر بنجاح',
              icon: Icons.edit_note_rounded,
              iconStartColor: const Color(0xFFC47A3D),
              iconEndColor: const Color(0xFFF6D38B),
            );
          },
        );
      },
    );
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AvailabilityConfirmDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          color: color,
          onConfirm: onConfirm,
        );
      },
    );
  }

  Future<void> _showSuccessPopup({
    required String title,
    required String message,
    required IconData icon,
    Color iconStartColor = const Color(0xFF16A34A),
    Color iconEndColor = const Color(0xFF86EFAC),
  }) async {
    if (!mounted) return;

    await showBarberFeedbackPopup(
      context: context,
      title: title,
      message: message,
      icon: icon,
      iconStartColor: iconStartColor,
      iconEndColor: iconEndColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final Color pageBackground = Theme.of(context).scaffoldBackgroundColor;
        final Color appBarTextColor =
            Theme.of(context).appBarTheme.iconTheme?.color ??
            Theme.of(context).colorScheme.onSurface;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              title: Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: appBarTextColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: pageBackground,
              surfaceTintColor: pageBackground,
              elevation: 0,
              iconTheme: IconThemeData(color: appBarTextColor),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const AvailabilityIntroCard(),

                const SizedBox(height: 14),

                AvailabilitySubnav(
                  selectedTab: controller.selectedTab,
                  onChanged: controller.changeTab,
                ),

                const SizedBox(height: 16),

                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 42),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: controller.loadAvailability,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                else if (controller.isClosuresTab) ...[
                  ClosureAddCard(
                    selectedDateLabel: controller.dateLabel(
                      controller.selectedClosureDate,
                    ),
                    reasonController: controller.closureReasonController,
                    onPickDate: _pickClosureDate,
                    onAdd: _addClosure,
                    dateErrorText: controller.closureDateError,
                    hasDateError: controller.closureDateError != null,
                    dateShakeTrigger: controller.closureDateShakeTrigger,
                    onReset: controller.resetClosureForm,
                  ),

                  const SizedBox(height: 16),

                  ClosuresList(
                    closures: controller.closures,
                    onEdit: _editClosure,
                    onDelete: _deleteClosure,
                  ),
                ] else ...[
                  TimeBlockAddCard(
                    selectedMode: controller.timeBlockMode,
                    onModeChanged: controller.changeTimeBlockMode,
                    selectedDateLabel: controller.dateLabel(
                      controller.selectedTimeBlockDate,
                    ),
                    startTimeLabel: controller.formatTime(
                      controller.selectedStartTime,
                    ),
                    endTimeLabel: controller.formatTime(
                      controller.selectedEndTime,
                    ),
                    reasonController: controller.timeBlockReasonController,
                    onPickDate: _pickTimeBlockDate,
                    onPickStartTime: _pickStartTime,
                    onPickEndTime: _pickEndTime,
                    onAdd: _addTimeBlock,
                    dateErrorText: controller.timeBlockDateError,
                    hasDateError: controller.timeBlockDateError != null,
                    dateShakeTrigger: controller.timeBlockDateShakeTrigger,
                    startTimeErrorText: controller.timeBlockStartError,
                    hasStartTimeError: controller.timeBlockStartError != null,
                    startTimeShakeTrigger:
                        controller.timeBlockStartShakeTrigger,
                    endTimeErrorText: controller.timeBlockEndError,
                    hasEndTimeError: controller.timeBlockEndError != null,
                    endTimeShakeTrigger: controller.timeBlockEndShakeTrigger,
                    onReset: controller.resetTimeBlockForm,
                  ),

                  const SizedBox(height: 16),

                  TimeBlocksList(
                    timeBlocks: controller.timeBlocks,
                    formatTime: controller.formatTime,
                    onEdit: _editTimeBlock,
                    onDelete: _deleteTimeBlock,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
