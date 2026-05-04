import 'package:flutter/material.dart';

import '../../utils/app_theme_colors.dart';
import '../../models/mock_appointment.dart';
import '../../models/summary_models.dart';
import '../../widgets/barber/summary/summary_filters_card.dart';
import '../../widgets/barber/summary/summary_mini_strip.dart';
import '../../widgets/barber/summary/summary_grid.dart';
import '../../widgets/barber/summary/summary_appointments_preview_section.dart';
import '../../widgets/barber/summary/summary_distribution_section.dart';
import '../../widgets/barber/summary/summary_insights_section.dart';
import '../../widgets/barber/summary/summary_intro_card.dart';

class BarberSummaryScreen extends StatefulWidget {
  const BarberSummaryScreen({super.key});

  @override
  State<BarberSummaryScreen> createState() => _BarberSummaryScreenState();
}

class _BarberSummaryScreenState extends State<BarberSummaryScreen> {
  int selectedFilter = 0;
  DateTime? selectedSpecificDate;

  final List<String> filters = const [
    'اليوم',
    'الأسبوع',
    'الشهر',
    'تاريخ محدد',
  ];

  late final List<SummarySnapshot> snapshots;

  @override
  void initState() {
    super.initState();

    snapshots = [
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
          DistributionItem(
            label: 'مكتملة',
            value: 34,
            color: Color(0xFF2E8B57),
          ),
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
          DistributionItem(
            label: 'مكتملة',
            value: 141,
            color: Color(0xFF2E8B57),
          ),
          DistributionItem(label: 'ملغية', value: 18, color: Color(0xFFD9534F)),
          DistributionItem(label: 'معلقة', value: 27, color: Color(0xFFC68A2D)),
        ],
      ),
    ];
  }

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

  Future<void> _pickSpecificDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedSpecificDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
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
      selectedSpecificDate = pickedDate;
      selectedFilter = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SummarySnapshot snapshot = currentSnapshot;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const SummaryIntroCard(),

            const SizedBox(height: 14),

            SummaryFiltersCard(
              filters: filters,
              selectedFilter: selectedFilter,
              selectedSpecificDate: selectedSpecificDate,
              onSelect: (index) {
                if (index == 3) {
                  _pickSpecificDate();
                  return;
                }

                setState(() {
                  selectedFilter = index;
                });
              },
            ),

            const SizedBox(height: 14),

            SummaryMiniStrip(snapshot: snapshot),

            const SizedBox(height: 14),

            SummaryGrid(snapshot: snapshot),

            const SizedBox(height: 16),

            InsightsSection(snapshot: snapshot),

            const SizedBox(height: 16),

            DistributionSection(snapshot: snapshot),

            const SizedBox(height: 16),

            AppointmentsPreviewSection(
              filterLabel: snapshot.filterLabel,
              appointments: previewAppointments,
            ),
          ],
        ),
      ),
    );
  }
}
