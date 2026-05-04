import 'package:flutter/material.dart';

import '../../models/availability_models.dart';
import '../../widgets/barber/availability/availability_intro_card.dart';
import '../../widgets/barber/availability/availability_subnav.dart';
import '../../widgets/barber/availability/availability_add_cards.dart';
import '../../widgets/barber/availability/availability_lists.dart';
import '../../widgets/barber/availability/edit_closure_sheet.dart';
import '../../widgets/barber/availability/edit_time_block_sheet.dart';
import '../../widgets/barber/availability/availability_confirm_dialog.dart';

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

  String timeBlockMode = 'recurring';
  DateTime? selectedTimeBlockDate;
  String selectedStartTime = '13:00';
  String selectedEndTime = '14:00';

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
    );

    if (pickedDate == null) return;

    setState(() {
      selectedClosureDate = pickedDate;
    });
  }

  Future<void> _pickTimeBlockDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedTimeBlockDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedTimeBlockDate = pickedDate;
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
    if (selectedClosureDate == null) {
      _showMessage('يرجى اختيار تاريخ الإغلاق');
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
    });

    _showMessage('تمت إضافة يوم الإغلاق بنجاح');
  }

  void _addTimeBlock() {
    if (timeBlockMode == 'specific' && selectedTimeBlockDate == null) {
      _showMessage('يرجى اختيار تاريخ فترة عدم التوفر');
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
    });

    _showMessage('تمت إضافة فترة عدم التوفر بنجاح');
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

        _showMessage('تم حذف يوم الإغلاق');
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

        _showMessage('تم حذف فترة عدم التوفر');
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

            _showMessage('تم تعديل يوم الإغلاق');
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
          onMessage: _showMessage,
          onSave: (updatedBlock) {
            setState(() {
              timeBlocks = timeBlocks.map((item) {
                if (item.id != updatedBlock.id) return item;
                return updatedBlock;
              }).toList();
            });

            _showMessage('تم تعديل فترة عدم التوفر');
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosuresTab = selectedTab == 'closures';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
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
                onReset: () {
                  setState(() {
                    selectedClosureDate = null;
                    _closureReasonController.clear();
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
                onReset: () {
                  setState(() {
                    timeBlockMode = 'recurring';
                    selectedTimeBlockDate = null;
                    selectedStartTime = '13:00';
                    selectedEndTime = '14:00';
                    timeBlockReasonController.clear();
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
