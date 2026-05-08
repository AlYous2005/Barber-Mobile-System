import 'package:flutter/material.dart';

import '../../models/working_day_model.dart';
import '../../repositories/barber_working_hours_repository.dart';
import '../../services/auth_session.dart';

class BarberWorkingHoursController extends ChangeNotifier {
  BarberWorkingHoursController({
    BarberWorkingHoursRepository workingHoursRepository =
        const BarberWorkingHoursRepository(),
  }) : _workingHoursRepository = workingHoursRepository;

  final BarberWorkingHoursRepository _workingHoursRepository;

  List<WorkingDay> workingDays =
      BarberWorkingHoursRepository.defaultWorkingDays;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> loadWorkingDays() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_currentBarberId.isEmpty) {
        throw Exception('Missing current barber id');
      }

      workingDays = await _workingHoursRepository.getWorkingDays(
        barberId: _currentBarberId,
      );
    } catch (error, stackTrace) {
      debugPrint('BarberWorkingHoursController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر تحميل ساعات العمل، حاول مرة أخرى';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWorkingDay(WorkingDay updatedDay) async {
    if (_currentBarberId.isEmpty) {
      throw Exception('Missing current barber id');
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final savedDay = await _workingHoursRepository.updateWorkingDay(
        barberId: _currentBarberId,
        day: updatedDay,
      );

      workingDays = workingDays.map((item) {
        if (item.dayOfWeek != savedDay.dayOfWeek) {
          return item;
        }

        return savedDay;
      }).toList();
    } catch (error, stackTrace) {
      debugPrint('BarberWorkingHoursController save error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر حفظ ساعات العمل، حاول مرة أخرى';
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
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
}
