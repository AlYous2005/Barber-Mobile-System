import 'package:flutter/material.dart';

import '../../models/availability_models.dart';
import '../../repositories/barber_availability_repository.dart';
import '../../services/auth_session.dart';

class BarberAvailabilityController extends ChangeNotifier {
  BarberAvailabilityController({
    BarberAvailabilityRepository availabilityRepository =
        const BarberAvailabilityRepository(),
  }) : _availabilityRepository = availabilityRepository;

  final BarberAvailabilityRepository _availabilityRepository;

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

  List<ClosureDay> closures = [];
  List<TimeBlock> timeBlocks = [];

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  bool get isClosuresTab => selectedTab == 'closures';

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> loadAvailability() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_currentBarberId.isEmpty) {
        throw Exception('Missing current barber id');
      }

      final loadedClosures = await _availabilityRepository.getClosures(
        barberId: _currentBarberId,
      );

      final loadedTimeBlocks = await _availabilityRepository.getTimeBlocks(
        barberId: _currentBarberId,
      );

      closures = loadedClosures;
      timeBlocks = loadedTimeBlocks;
    } catch (error, stackTrace) {
      debugPrint('BarberAvailabilityController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر تحميل بيانات التوفر، حاول مرة أخرى';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

  Future<bool> addClosure() async {
    closureDateError = null;

    if (selectedClosureDate == null) {
      closureDateError = 'يرجى اختيار تاريخ الإغلاق';
      closureDateShakeTrigger++;
      notifyListeners();
      return false;
    }

    if (_currentBarberId.isEmpty) {
      errorMessage = 'تعذر معرفة حساب الحلاق الحالي';
      notifyListeners();
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      final savedClosure = await _availabilityRepository.addClosure(
        barberId: _currentBarberId,
        closureDate: selectedClosureDate!,
        reason: closureReasonController.text,
      );

      closures = [
        savedClosure,
        ...closures.where((item) => item.id != savedClosure.id),
      ];

      selectedClosureDate = null;
      closureReasonController.clear();
      closureDateError = null;

      return true;
    } catch (error, stackTrace) {
      debugPrint('BarberAvailabilityController add closure error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر إضافة يوم الإغلاق، حاول مرة أخرى';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> addTimeBlock() async {
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

    if (_currentBarberId.isEmpty) {
      errorMessage = 'تعذر معرفة حساب الحلاق الحالي';
      notifyListeners();
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      final savedBlock = await _availabilityRepository.addTimeBlock(
        barberId: _currentBarberId,
        blockType: timeBlockMode,
        blockDate: selectedTimeBlockDate,
        startTime: selectedStartTime,
        endTime: selectedEndTime,
        reason: timeBlockReasonController.text,
      );

      timeBlocks = [savedBlock, ...timeBlocks];

      resetTimeBlockForm();
      return true;
    } catch (error, stackTrace) {
      debugPrint('BarberAvailabilityController add time block error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر إضافة فترة عدم التوفر، حاول مرة أخرى';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteClosure(ClosureDay closure) async {
    await _availabilityRepository.deleteClosure(closureId: closure.id);

    closures = closures.where((item) => item.id != closure.id).toList();
    notifyListeners();
  }

  Future<void> deleteTimeBlock(TimeBlock block) async {
    await _availabilityRepository.deleteTimeBlock(blockId: block.id);

    timeBlocks = timeBlocks.where((item) => item.id != block.id).toList();
    notifyListeners();
  }

  Future<void> updateClosure(ClosureDay updatedClosure) async {
    final savedClosure = await _availabilityRepository.updateClosure(
      closure: updatedClosure,
    );

    closures = closures.map((item) {
      if (item.id != savedClosure.id) return item;
      return savedClosure;
    }).toList();

    notifyListeners();
  }

  Future<void> updateTimeBlock(TimeBlock updatedBlock) async {
    final savedBlock = await _availabilityRepository.updateTimeBlock(
      block: updatedBlock,
    );

    timeBlocks = timeBlocks.map((item) {
      if (item.id != savedBlock.id) return item;
      return savedBlock;
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
