// filters + selected date + snapshots + preview appointments

import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../models/summary_models.dart';
import '../../data/mocks/mock_appointments.dart';

class BarberSummaryController extends ChangeNotifier {
  int selectedFilter = 0;
  DateTime? selectedSpecificDate;

  final List<String> filters = const [
    'اليوم',
    'الأسبوع',
    'الشهر',
    'تاريخ محدد',
  ];

  late final List<SummarySnapshot> snapshots = [
    SummarySnapshot(
      filterLabel: 'اليوم',
      totalAppointments: 12,
      completedAppointments: 8,
      cancelledAppointments: 2,
      pendingAppointments: 2,
      revenue: 420,
      completionRate: '67%',
      bestService: 'حلاقة شعر',
      averageTicket: '35 ₪',
      activeCustomers: 9,
      topHour: '6:00 مساءً',
      distribution: const [
        DistributionItem(label: 'مكتملة', value: 8, color: Color(0xFF2E8B57)),
        DistributionItem(label: 'ملغية', value: 2, color: Color(0xFFD9534F)),
        DistributionItem(label: 'معلقة', value: 2, color: Color(0xFFC68A2D)),
      ],
    ),
    SummarySnapshot(
      filterLabel: 'الأسبوع',
      totalAppointments: 47,
      completedAppointments: 34,
      cancelledAppointments: 6,
      pendingAppointments: 7,
      revenue: 1680,
      completionRate: '72%',
      bestService: 'حلاقة شعر + لحية',
      averageTicket: '41 ₪',
      activeCustomers: 28,
      topHour: '5:30 مساءً',
      distribution: const [
        DistributionItem(label: 'مكتملة', value: 34, color: Color(0xFF2E8B57)),
        DistributionItem(label: 'ملغية', value: 6, color: Color(0xFFD9534F)),
        DistributionItem(label: 'معلقة', value: 7, color: Color(0xFFC68A2D)),
      ],
    ),
    SummarySnapshot(
      filterLabel: 'الشهر',
      totalAppointments: 186,
      completedAppointments: 141,
      cancelledAppointments: 18,
      pendingAppointments: 27,
      revenue: 6840,
      completionRate: '76%',
      bestService: 'حلاقة شعر + لحية',
      averageTicket: '43 ₪',
      activeCustomers: 92,
      topHour: '7:00 مساءً',
      distribution: const [
        DistributionItem(label: 'مكتملة', value: 141, color: Color(0xFF2E8B57)),
        DistributionItem(label: 'ملغية', value: 18, color: Color(0xFFD9534F)),
        DistributionItem(label: 'معلقة', value: 27, color: Color(0xFFC68A2D)),
      ],
    ),
  ];

  SummarySnapshot get currentSnapshot {
    if (selectedFilter == 3) {
      final String dateLabel = selectedSpecificDate == null
          ? 'تاريخ محدد'
          : '${selectedSpecificDate!.day}/${selectedSpecificDate!.month}/${selectedSpecificDate!.year}';

      return SummarySnapshot(
        filterLabel: dateLabel,
        totalAppointments: 6,
        completedAppointments: 4,
        cancelledAppointments: 1,
        pendingAppointments: 1,
        revenue: 210,
        completionRate: '67%',
        bestService: 'حلاقة شعر',
        averageTicket: '35 ₪',
        activeCustomers: 5,
        topHour: '6:30 مساءً',
        distribution: const [
          DistributionItem(label: 'مكتملة', value: 4, color: Color(0xFF2E8B57)),
          DistributionItem(label: 'ملغية', value: 1, color: Color(0xFFD9534F)),
          DistributionItem(label: 'معلقة', value: 1, color: Color(0xFFC68A2D)),
        ],
      );
    }

    return snapshots[selectedFilter];
  }

  List<MockAppointment> get previewAppointments {
    return mockBarberAppointments.take(3).toList();
  }

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }

  void selectSpecificDate(DateTime date) {
    selectedSpecificDate = date;
    selectedFilter = 3;
    notifyListeners();
  }
}
