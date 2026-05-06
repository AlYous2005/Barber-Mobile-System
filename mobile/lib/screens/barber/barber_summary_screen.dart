// UI + date picker

import 'package:flutter/material.dart';

import '../../controllers/barber/barber_summary_controller.dart';
import '../../models/summary_models.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/barber/summary/summary_appointments_preview_section.dart';
import '../../widgets/barber/summary/summary_distribution_section.dart';
import '../../widgets/barber/summary/summary_filters_card.dart';
import '../../widgets/barber/summary/summary_grid.dart';
import '../../widgets/barber/summary/summary_insights_section.dart';
import '../../widgets/barber/summary/summary_intro_card.dart';
import '../../widgets/barber/summary/summary_mini_strip.dart';

class BarberSummaryScreen extends StatefulWidget {
  const BarberSummaryScreen({super.key});

  @override
  State<BarberSummaryScreen> createState() => _BarberSummaryScreenState();
}

class _BarberSummaryScreenState extends State<BarberSummaryScreen> {
  late final BarberSummaryController controller;

  @override
  void initState() {
    super.initState();
    controller = BarberSummaryController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickSpecificDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedSpecificDate ?? now,
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

    controller.selectSpecificDate(pickedDate);
  }

  void _handleFilterSelect(int index) {
    if (index == 3) {
      _pickSpecificDate();
      return;
    }

    controller.selectFilter(index);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final SummarySnapshot snapshot = controller.currentSnapshot;

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
                  filters: controller.filters,
                  selectedFilter: controller.selectedFilter,
                  selectedSpecificDate: controller.selectedSpecificDate,
                  onSelect: _handleFilterSelect,
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
                  appointments: controller.previewAppointments,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
