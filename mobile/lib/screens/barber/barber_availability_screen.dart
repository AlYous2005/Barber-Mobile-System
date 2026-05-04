import 'package:flutter/material.dart';

import '../../models/availability_models.dart';
import '../../widgets/barber/availability/availability_intro_card.dart';
import '../../widgets/barber/availability/availability_subnav.dart';
import '../../widgets/barber/availability/availability_add_cards.dart';
import '../../widgets/barber/availability/availability_lists.dart';
import '../../widgets/barber/availability/edit_closure_sheet.dart';
import '../../widgets/barber/availability/edit_time_block_sheet.dart';
import '../../widgets/barber/availability/availability_confirm_dialog.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

class BarberAvailabilityScreen extends StatefulWidget {
  const BarberAvailabilityScreen({super.key});

  @override
  State<BarberAvailabilityScreen> createState() =>
      _BarberAvailabilityScreenState();
}

class _BarberAvailabilityScreenState extends State<BarberAvailabilityScreen> {
  String selectedTab = 'closures';

  final TextEditingController _closureReasonController =
      TextEditingController();
  final TextEditingController timeBlockReasonController =
      TextEditingController();

  DateTime? selectedClosureDate;
  String? closureDateError;
  int closureDateShakeTrigger = 0;

  String timeBlockMode = 'recurring';
  DateTime? selectedTimeBlockDate;
  String selectedStartTime = '13:00';
  String selectedEndTime = '14:00';
  String? timeBlockDateError;
  String? timeBlockStartError;
  String? timeBlockEndError;
  int timeBlockDateShakeTrigger = 0;
  int timeBlockStartShakeTrigger = 0;
  int timeBlockEndShakeTrigger = 0;

  late List<ClosureDay> closures;
  late List<TimeBlock> timeBlocks;

  @override
  void initState() {
    super.initState();

    closures = [
      ClosureDay(id: 'c1', dateLabel: '15/5/2026', reason: 'إجازة خاصة'),
      ClosureDay(id: 'c2', dateLabel: '22/5/2026', reason: 'ظرف طارئ'),
    ];

    timeBlocks = [
      TimeBlock(
        id: 't1',
        type: 'recurring',
        dateLabel: null,
        startTime: '13:00',
        endTime: '14:00',
        reason: 'استراحة غداء',
      ),
      TimeBlock(
        id: 't2',
        type: 'specific',
        dateLabel: '18/5/2026',
        startTime: '17:00',
        endTime: '18:30',
        reason: 'مشوار خاص',
      ),
    ];
  }

  @override
  void dispose() {
    _closureReasonController.dispose();
    timeBlockReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickClosureDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedClosureDate ?? now,
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

    setState(() {
      selectedClosureDate = pickedDate;
      closureDateError = null;
    });
  }

  Future<void> _pickTimeBlockDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedTimeBlockDate ?? now,
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

    setState(() {
      selectedTimeBlockDate = pickedDate;
      timeBlockDateError = null;
    });
  }

  Future<void> _pickStartTime() async {
    final String? picked = await _pickTime(
      context: context,
      initialValue: selectedStartTime,
    );

    if (picked == null) return;

    setState(() {
      selectedStartTime = picked;
      timeBlockStartError = null;
    });
  }

  Future<void> _pickEndTime() async {
    final String? picked = await _pickTime(
      context: context,
      initialValue: selectedEndTime,
    );

    if (picked == null) return;

    setState(() {
      selectedEndTime = picked;
      timeBlockEndError = null;
    });
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

  void _addClosure() {
    setState(() {
      closureDateError = null;
    });

    if (selectedClosureDate == null) {
      setState(() {
        closureDateError = 'يرجى اختيار تاريخ الإغلاق';
        closureDateShakeTrigger++;
      });
      return;
    }

    final String reason = _closureReasonController.text.trim();

    setState(() {
      closures.insert(
        0,
        ClosureDay(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          dateLabel: _dateLabel(selectedClosureDate),
          reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
        ),
      );

      selectedClosureDate = null;
      _closureReasonController.clear();
      closureDateError = null;
    });
    _showSuccessPopup(
      title: 'تمت إضافة يوم الإغلاق',
      message: 'تمت إضافة يوم الإغلاق بنجاح',
      icon: Icons.event_busy_rounded,
      iconStartColor: const Color(0xFF16A34A),
      iconEndColor: const Color(0xFF86EFAC),
    );
  }

  void _addTimeBlock() {
    setState(() {
      timeBlockDateError = null;
      timeBlockStartError = null;
      timeBlockEndError = null;
    });

    if (timeBlockMode == 'specific' && selectedTimeBlockDate == null) {
      setState(() {
        timeBlockDateError = 'يرجى اختيار تاريخ فترة عدم التوفر';
        timeBlockDateShakeTrigger++;
      });
      return;
    }

    if (selectedStartTime.trim().isEmpty) {
      setState(() {
        timeBlockStartError = 'يرجى اختيار وقت البداية';
        timeBlockStartShakeTrigger++;
      });
      return;
    }

    if (selectedEndTime.trim().isEmpty) {
      setState(() {
        timeBlockEndError = 'يرجى اختيار وقت النهاية';
        timeBlockEndShakeTrigger++;
      });
      return;
    }

    if (!_isStartBeforeEnd(selectedStartTime, selectedEndTime)) {
      setState(() {
        timeBlockEndError = 'وقت البداية يجب أن يكون قبل وقت النهاية';
        timeBlockStartShakeTrigger++;
        timeBlockEndShakeTrigger++;
      });
      return;
    }

    final String reason = timeBlockReasonController.text.trim();

    setState(() {
      timeBlocks.insert(
        0,
        TimeBlock(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: timeBlockMode,
          dateLabel: timeBlockMode == 'specific'
              ? _dateLabel(selectedTimeBlockDate)
              : null,
          startTime: selectedStartTime,
          endTime: selectedEndTime,
          reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
        ),
      );

      selectedTimeBlockDate = null;
      selectedStartTime = '13:00';
      selectedEndTime = '14:00';
      timeBlockReasonController.clear();
      timeBlockMode = 'recurring';
      timeBlockDateError = null;
      timeBlockStartError = null;
      timeBlockEndError = null;
    });
    _showSuccessPopup(
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
      onConfirm: () {
        setState(() {
          closures.removeWhere((item) => item.id == closure.id);
        });
        _showSuccessPopup(
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
          'هل تريد حذف الفترة من ${_formatTime(block.startTime)} إلى ${_formatTime(block.endTime)}؟',
      confirmText: 'حذف',
      color: const Color(0xFFEF4444),
      onConfirm: () {
        setState(() {
          timeBlocks.removeWhere((item) => item.id == block.id);
        });
        _showSuccessPopup(
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
          onSave: (updatedClosure) {
            setState(() {
              closures = closures.map((item) {
                if (item.id != updatedClosure.id) return item;
                return updatedClosure;
              }).toList();
            });
            _showSuccessPopup(
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
          onSave: (updatedBlock) {
            setState(() {
              timeBlocks = timeBlocks.map((item) {
                if (item.id != updatedBlock.id) return item;
                return updatedBlock;
              }).toList();
            });
            _showSuccessPopup(
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
    final bool isClosuresTab = selectedTab == 'closures';
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
              selectedTab: selectedTab,
              onChanged: (value) {
                setState(() {
                  selectedTab = value;
                });
              },
            ),

            const SizedBox(height: 16),

            if (isClosuresTab) ...[
              ClosureAddCard(
                selectedDateLabel: _dateLabel(selectedClosureDate),
                reasonController: _closureReasonController,
                onPickDate: _pickClosureDate,
                onAdd: _addClosure,
                dateErrorText: closureDateError,
                hasDateError: closureDateError != null,
                dateShakeTrigger: closureDateShakeTrigger,
                onReset: () {
                  setState(() {
                    selectedClosureDate = null;
                    _closureReasonController.clear();
                    closureDateError = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              ClosuresList(
                closures: closures,
                onEdit: _editClosure,
                onDelete: _deleteClosure,
              ),
            ] else ...[
              TimeBlockAddCard(
                selectedMode: timeBlockMode,
                onModeChanged: (value) {
                  setState(() {
                    timeBlockMode = value;
                    timeBlockDateError = null;
                  });
                },
                selectedDateLabel: _dateLabel(selectedTimeBlockDate),
                startTimeLabel: _formatTime(selectedStartTime),
                endTimeLabel: _formatTime(selectedEndTime),
                reasonController: timeBlockReasonController,
                onPickDate: _pickTimeBlockDate,
                onPickStartTime: _pickStartTime,
                onPickEndTime: _pickEndTime,
                onAdd: _addTimeBlock,
                dateErrorText: timeBlockDateError,
                hasDateError: timeBlockDateError != null,
                dateShakeTrigger: timeBlockDateShakeTrigger,
                startTimeErrorText: timeBlockStartError,
                hasStartTimeError: timeBlockStartError != null,
                startTimeShakeTrigger: timeBlockStartShakeTrigger,
                endTimeErrorText: timeBlockEndError,
                hasEndTimeError: timeBlockEndError != null,
                endTimeShakeTrigger: timeBlockEndShakeTrigger,
                onReset: () {
                  setState(() {
                    timeBlockMode = 'recurring';
                    selectedTimeBlockDate = null;
                    selectedStartTime = '13:00';
                    selectedEndTime = '14:00';
                    timeBlockReasonController.clear();
                    timeBlockDateError = null;
                    timeBlockStartError = null;
                    timeBlockEndError = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              TimeBlocksList(
                timeBlocks: timeBlocks,
                formatTime: _formatTime,
                onEdit: _editTimeBlock,
                onDelete: _deleteTimeBlock,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
