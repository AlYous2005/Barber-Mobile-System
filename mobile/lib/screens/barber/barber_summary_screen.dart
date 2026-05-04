import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';

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

  late final List<_SummarySnapshot> snapshots;

  @override
  void initState() {
    super.initState();

    snapshots = [
      _SummarySnapshot(
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
          _DistributionItem(
            label: 'مكتملة',
            value: 8,
            color: Color(0xFF2E8B57),
          ),
          _DistributionItem(label: 'ملغية', value: 2, color: Color(0xFFD9534F)),
          _DistributionItem(label: 'معلقة', value: 2, color: Color(0xFFC68A2D)),
        ],
      ),
      _SummarySnapshot(
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
          _DistributionItem(
            label: 'مكتملة',
            value: 34,
            color: Color(0xFF2E8B57),
          ),
          _DistributionItem(label: 'ملغية', value: 6, color: Color(0xFFD9534F)),
          _DistributionItem(label: 'معلقة', value: 7, color: Color(0xFFC68A2D)),
        ],
      ),
      _SummarySnapshot(
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
          _DistributionItem(
            label: 'مكتملة',
            value: 141,
            color: Color(0xFF2E8B57),
          ),
          _DistributionItem(
            label: 'ملغية',
            value: 18,
            color: Color(0xFFD9534F),
          ),
          _DistributionItem(
            label: 'معلقة',
            value: 27,
            color: Color(0xFFC68A2D),
          ),
        ],
      ),
    ];
  }

  _SummarySnapshot get currentSnapshot {
    if (selectedFilter == 3) {
      final String dateLabel = selectedSpecificDate == null
          ? 'تاريخ محدد'
          : '${selectedSpecificDate!.day}/${selectedSpecificDate!.month}/${selectedSpecificDate!.year}';

      return _SummarySnapshot(
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
          _DistributionItem(
            label: 'مكتملة',
            value: 4,
            color: Color(0xFF2E8B57),
          ),
          _DistributionItem(label: 'ملغية', value: 1, color: Color(0xFFD9534F)),
          _DistributionItem(label: 'معلقة', value: 1, color: Color(0xFFC68A2D)),
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
    );

    if (pickedDate == null) return;

    setState(() {
      selectedSpecificDate = pickedDate;
      selectedFilter = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _SummarySnapshot snapshot = currentSnapshot;

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
            const _SummaryIntroCard(),

            const SizedBox(height: 14),

            _SummaryFiltersCard(
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

            _SummaryMiniStrip(snapshot: snapshot),

            const SizedBox(height: 14),

            _SummaryGrid(snapshot: snapshot),

            const SizedBox(height: 16),

            _InsightsSection(snapshot: snapshot),

            const SizedBox(height: 16),

            _DistributionSection(snapshot: snapshot),

            const SizedBox(height: 16),

            _AppointmentsPreviewSection(
              filterLabel: snapshot.filterLabel,
              appointments: previewAppointments,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryIntroCard extends StatelessWidget {
  const _SummaryIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6E3F2F), Color(0xFF9B5A3D), Color(0xFFC37A49)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryCenterPill(),
          SizedBox(height: 14),
          Text(
            'الملخصات والإنجازات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'تتبّع الأداء والإيرادات والمواعيد بطريقة واضحة واحترافية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCenterPill extends StatelessWidget {
  const _SummaryCenterPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Achievements Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SummaryFiltersCard extends StatelessWidget {
  const _SummaryFiltersCard({
    required this.filters,
    required this.selectedFilter,
    required this.selectedSpecificDate,
    required this.onSelect,
  });

  final List<String> filters;
  final int selectedFilter;
  final DateTime? selectedSpecificDate;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEADBCD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: Color(0xFF9A5A38),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'فلترة الملخصات',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(filters.length, (index) {
              final bool isSelected = selectedFilter == index;
              return _FilterPillButton(
                label: index == 3 && selectedSpecificDate != null
    ? '${selectedSpecificDate!.day}/${selectedSpecificDate!.month}/${selectedSpecificDate!.year}'
    : filters[index],
                isSelected: isSelected,
                onTap: () => onSelect(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterPillButton extends StatelessWidget {
  const _FilterPillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF9A5A38) : const Color(0xFFF7EEE6),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF9A5A38)
                  : const Color(0xFFE3D3C6),
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x229A5A38),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : const Color(0xFF6B4F3E),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMiniStrip extends StatelessWidget {
  const _SummaryMiniStrip({required this.snapshot});

  final _SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDF7F1), Color(0xFFF7EEE6)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7D7CB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9A5A38), Color(0xFFB8774A)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص ${snapshot.filterLabel}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'إجمالي المواعيد: ${snapshot.totalAppointments} • الإيرادات: ${snapshot.revenue} ₪',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B5D52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.snapshot});

  final _SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCardData(
        title: 'إجمالي المواعيد',
        value: '${snapshot.totalAppointments}',
        subtitle: 'لكل ${snapshot.filterLabel}',
        color: const Color(0xFF3B82F6),
        icon: Icons.calendar_month_rounded,
      ),
      _SummaryCardData(
        title: 'المواعيد المكتملة',
        value: '${snapshot.completedAppointments}',
        subtitle: 'مواعيد منجزة',
        color: const Color(0xFF22C55E),
        icon: Icons.check_circle_rounded,
      ),
      _SummaryCardData(
        title: 'المواعيد الملغية',
        value: '${snapshot.cancelledAppointments}',
        subtitle: 'تم إلغاؤها',
        color: const Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
      ),
      _SummaryCardData(
        title: 'الإيرادات',
        value: '${snapshot.revenue} ₪',
        subtitle: 'الدخل الإجمالي',
        color: const Color(0xFFF59E0B),
        icon: Icons.payments_rounded,
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return _SummaryCard(data: cards[index]);
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: data.color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.color, size: 22),
            ),
          ),
          const Spacer(),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2A2018),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: data.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.snapshot});

  final _SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final insights = [
      _InsightData(
        title: 'نسبة الإنجاز',
        value: snapshot.completionRate,
        subtitle: 'من إجمالي المواعيد',
        icon: Icons.insights_rounded,
        color: const Color(0xFF2563EB),
      ),
      _InsightData(
        title: 'الخدمة الأفضل',
        value: snapshot.bestService,
        subtitle: 'الأكثر طلبًا',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFF16A34A),
      ),
      _InsightData(
        title: 'متوسط التذكرة',
        value: snapshot.averageTicket,
        subtitle: 'لكل زبون',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _InsightData(
        title: 'الزبائن النشطون',
        value: '${snapshot.activeCustomers}',
        subtitle: 'في هذه الفترة',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      _InsightData(
        title: 'الوقت الذهبي',
        value: snapshot.topHour,
        subtitle: 'أعلى ضغط',
        icon: Icons.schedule_rounded,
        color: const Color(0xFFEC4899),
      ),
      _InsightData(
        title: 'المواعيد المعلقة',
        value: '${snapshot.pendingAppointments}',
        subtitle: 'بانتظار الإجراء',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFC68A2D),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEADBCD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_graph_rounded,
                color: Color(0xFF9A5A38),
                size: 21,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الرؤى والمؤشرات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...insights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightCard(data: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});

  final _InsightData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              data.value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: data.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionSection extends StatelessWidget {
  const _DistributionSection({required this.snapshot});

  final _SummarySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final int total = snapshot.distribution.fold(
      0,
      (sum, item) => sum + item.value,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEADBCD)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF9A5A38), size: 21),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'توزيع الحالات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...snapshot.distribution.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DistributionBar(item: item, total: total),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.item, required this.total});

  final _DistributionItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double ratio = total == 0 ? 0 : item.value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2A2018),
                ),
              ),
            ),
            Text(
              '${item.value}',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: item.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            color: const Color(0xFFF1E8DF),
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentsPreviewSection extends StatelessWidget {
  const _AppointmentsPreviewSection({
    required this.filterLabel,
    required this.appointments,
  });

  final String filterLabel;
  final List<MockAppointment> appointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEADBCD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: Color(0xFF9A5A38),
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'أبرز المواعيد - $filterLabel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...appointments.map(
            (appointment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PreviewAppointmentCard(appointment: appointment),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewAppointmentCard extends StatelessWidget {
  const _PreviewAppointmentCard({required this.appointment});

  final MockAppointment appointment;

  Color _statusColor(String status) {
    switch (status) {
      case 'مكتمل':
      case 'مكتملة':
        return const Color(0xFF22C55E);
      case 'ملغي':
      case 'ملغية':
        return const Color(0xFFEF4444);
      case 'قادم':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFC68A2D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(appointment.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EEE6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF6B4F3E),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.serviceName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.dateLabel} • ${appointment.timeLabel}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              appointment.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySnapshot {
  const _SummarySnapshot({
    required this.filterLabel,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.pendingAppointments,
    required this.revenue,
    required this.completionRate,
    required this.bestService,
    required this.averageTicket,
    required this.activeCustomers,
    required this.topHour,
    required this.distribution,
  });

  final String filterLabel;
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int pendingAppointments;
  final int revenue;
  final String completionRate;
  final String bestService;
  final String averageTicket;
  final int activeCustomers;
  final String topHour;
  final List<_DistributionItem> distribution;
}

class _DistributionItem {
  const _DistributionItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
}

class _InsightData {
  const _InsightData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}
