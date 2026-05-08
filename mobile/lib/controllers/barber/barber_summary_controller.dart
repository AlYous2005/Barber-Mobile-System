import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../models/summary_models.dart';
import '../../repositories/barber_summary_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../services/auth_session.dart';

class BarberSummaryController extends ChangeNotifier {
  BarberSummaryController({
    BarberSummaryRepository summaryRepository = const BarberSummaryRepository(),
    BookingRepository bookingRepository = const BookingRepository(),
  }) : _summaryRepository = summaryRepository,
       _bookingRepository = bookingRepository;

  final BarberSummaryRepository _summaryRepository;
  final BookingRepository _bookingRepository;

  int selectedFilter = 0;
  DateTime? selectedSpecificDate;

  bool isLoading = false;
  String? errorMessage;

  SummarySnapshot? _currentSnapshot;
  List<MockAppointment> previewAppointments = [];

  final List<String> filters = const [
    'اليوم',
    'الأسبوع',
    'الشهر',
    'تاريخ محدد',
  ];

  SummarySnapshot get currentSnapshot {
    return _currentSnapshot ?? _emptySnapshot('اليوم');
  }

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> loadSummary() async {
    if (_currentBarberId.isEmpty) {
      errorMessage = 'تعذر معرفة حساب الحلاق الحالي';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final range = _currentDateRange();
      final filterLabel = _currentFilterLabel();

      _currentSnapshot = await _summaryRepository.getSummarySnapshot(
        barberId: _currentBarberId,
        filterLabel: filterLabel,
        startDate: range.start,
        endDate: range.end,
      );

      await _loadPreviewAppointments(range: range);
    } catch (error, stackTrace) {
      debugPrint('BarberSummaryController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر تحميل الملخصات، حاول مرة أخرى';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPreviewAppointments({required _DateRange range}) async {
    final loadedAppointments = await _bookingRepository.getBarberAppointments(
      barberId: _currentBarberId,
    );

    final filteredAppointments =
        loadedAppointments.where((appointment) {
          final date = appointment.startDateTime;

          final normalizedDate = DateTime(date.year, date.month, date.day);
          final normalizedStart = DateTime(
            range.start.year,
            range.start.month,
            range.start.day,
          );
          final normalizedEnd = DateTime(
            range.end.year,
            range.end.month,
            range.end.day,
          );

          return !normalizedDate.isBefore(normalizedStart) &&
              !normalizedDate.isAfter(normalizedEnd);
        }).toList()..sort((first, second) {
          return second.startDateTime.compareTo(first.startDateTime);
        });

    previewAppointments = filteredAppointments.take(3).toList();
  }

  Future<void> selectFilter(int index) async {
    selectedFilter = index;

    if (index != 3) {
      selectedSpecificDate = null;
    }

    await loadSummary();
  }

  Future<void> selectSpecificDate(DateTime date) async {
    selectedSpecificDate = date;
    selectedFilter = 3;

    await loadSummary();
  }

  _DateRange _currentDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter) {
      case 1:
        final weekStart = today.subtract(Duration(days: today.weekday % 7));
        final weekEnd = weekStart.add(const Duration(days: 6));

        return _DateRange(start: weekStart, end: weekEnd);

      case 2:
        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 0);

        return _DateRange(start: monthStart, end: monthEnd);

      case 3:
        final selectedDate = selectedSpecificDate ?? today;
        final normalized = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );

        return _DateRange(start: normalized, end: normalized);

      case 0:
      default:
        return _DateRange(start: today, end: today);
    }
  }

  String _currentFilterLabel() {
    if (selectedFilter == 3) {
      final date = selectedSpecificDate;

      if (date == null) {
        return 'تاريخ محدد';
      }

      return '${date.day}/${date.month}/${date.year}';
    }

    return filters[selectedFilter];
  }

  SummarySnapshot _emptySnapshot(String label) {
    return SummarySnapshot(
      filterLabel: label,
      totalAppointments: 0,
      completedAppointments: 0,
      cancelledAppointments: 0,
      pendingAppointments: 0,
      revenue: 0,
      completionRate: '0%',
      bestService: 'لا يوجد',
      averageTicket: '0 ₪',
      activeCustomers: 0,
      topHour: 'لا يوجد',
      distribution: const [
        DistributionItem(label: 'مكتملة', value: 0, color: Color(0xFF2E8B57)),
        DistributionItem(label: 'ملغية', value: 0, color: Color(0xFFD9534F)),
        DistributionItem(label: 'معلقة', value: 0, color: Color(0xFFC68A2D)),
      ],
    );
  }
}

class _DateRange {
  const _DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
