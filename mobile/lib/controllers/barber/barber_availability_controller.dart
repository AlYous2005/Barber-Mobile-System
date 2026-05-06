// state + validation + add/edit/delete + format helpers

import 'package:flutter/material.dart';

import '../../models/availability_models.dart';

class BarberAvailabilityController extends ChangeNotifier {
  BarberAvailabilityController() {
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

  final TextEditingController closureReasonController = TextEditingController();
  final TextEditingController timeBlockReasonController =
      TextEditingController();

  String selectedTab = 'closures';

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

  bool get isClosuresTab => selectedTab == 'closures';

  void changeTab(String value) {
    selectedTab = value;
    notifyListeners();
  }

  void setClosureDate(DateTime date) {
    selectedClosureDate = date;
    closureDateError = null;
    notifyListeners();
  }

  void setTimeBlockDate(DateTime date) {
    selectedTimeBlockDate = date;
    timeBlockDateError = null;
    notifyListeners();
  }

  void setStartTime(String value) {
    selectedStartTime = value;
    timeBlockStartError = null;
    notifyListeners();
  }

  void setEndTime(String value) {
    selectedEndTime = value;
    timeBlockEndError = null;
    notifyListeners();
  }

  void changeTimeBlockMode(String value) {
    timeBlockMode = value;
    timeBlockDateError = null;
    notifyListeners();
  }

  void resetClosureForm() {
    selectedClosureDate = null;
    closureReasonController.clear();
    closureDateError = null;
    notifyListeners();
  }

  void resetTimeBlockForm() {
    timeBlockMode = 'recurring';
    selectedTimeBlockDate = null;
    selectedStartTime = '13:00';
    selectedEndTime = '14:00';
    timeBlockReasonController.clear();
    timeBlockDateError = null;
    timeBlockStartError = null;
    timeBlockEndError = null;
    notifyListeners();
  }

  bool addClosure() {
    closureDateError = null;

    if (selectedClosureDate == null) {
      closureDateError = 'يرجى اختيار تاريخ الإغلاق';
      closureDateShakeTrigger++;
      notifyListeners();
      return false;
    }

    final String reason = closureReasonController.text.trim();

    closures = [
      ClosureDay(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateLabel: dateLabel(selectedClosureDate),
        reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
      ),
      ...closures,
    ];

    selectedClosureDate = null;
    closureReasonController.clear();
    closureDateError = null;

    notifyListeners();
    return true;
  }

  bool addTimeBlock() {
    timeBlockDateError = null;
    timeBlockStartError = null;
    timeBlockEndError = null;

    if (timeBlockMode == 'specific' && selectedTimeBlockDate == null) {
      timeBlockDateError = 'يرجى اختيار تاريخ فترة عدم التوفر';
      timeBlockDateShakeTrigger++;
      notifyListeners();
      return false;
    }

    if (selectedStartTime.trim().isEmpty) {
      timeBlockStartError = 'يرجى اختيار وقت البداية';
      timeBlockStartShakeTrigger++;
      notifyListeners();
      return false;
    }

    if (selectedEndTime.trim().isEmpty) {
      timeBlockEndError = 'يرجى اختيار وقت النهاية';
      timeBlockEndShakeTrigger++;
      notifyListeners();
      return false;
    }

    if (!isStartBeforeEnd(selectedStartTime, selectedEndTime)) {
      timeBlockEndError = 'وقت البداية يجب أن يكون قبل وقت النهاية';
      timeBlockStartShakeTrigger++;
      timeBlockEndShakeTrigger++;
      notifyListeners();
      return false;
    }

    final String reason = timeBlockReasonController.text.trim();

    timeBlocks = [
      TimeBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: timeBlockMode,
        dateLabel: timeBlockMode == 'specific'
            ? dateLabel(selectedTimeBlockDate)
            : null,
        startTime: selectedStartTime,
        endTime: selectedEndTime,
        reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
      ),
      ...timeBlocks,
    ];

    resetTimeBlockForm();
    return true;
  }

  void deleteClosure(ClosureDay closure) {
    closures = closures.where((item) => item.id != closure.id).toList();
    notifyListeners();
  }

  void deleteTimeBlock(TimeBlock block) {
    timeBlocks = timeBlocks.where((item) => item.id != block.id).toList();
    notifyListeners();
  }

  void updateClosure(ClosureDay updatedClosure) {
    closures = closures.map((item) {
      if (item.id != updatedClosure.id) return item;
      return updatedClosure;
    }).toList();

    notifyListeners();
  }

  void updateTimeBlock(TimeBlock updatedBlock) {
    timeBlocks = timeBlocks.map((item) {
      if (item.id != updatedBlock.id) return item;
      return updatedBlock;
    }).toList();

    notifyListeners();
  }

  String dateLabel(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final time = TimeOfDay(hour: hour, minute: minute);
    final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final displayMinute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

    return '$displayHour:$displayMinute $period';
  }

  bool isStartBeforeEnd(String start, String end) {
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
  void dispose() {
    closureReasonController.dispose();
    timeBlockReasonController.dispose();
    super.dispose();
  }
}
