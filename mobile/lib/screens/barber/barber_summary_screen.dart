// UI + date picker

import 'package:flutter/material.dart';

import '../../controllers/barber/barber_summary_controller.dart';
import '../../features/barber/profile/barber_profile.dart';
import '../../general_utils/app_theme_colors.dart';
import '../../widgets/barber/summary/summary_appointments_preview_section.dart';
import '../../widgets/barber/summary/summary_distribution_section.dart';
import '../../widgets/barber/summary/summary_filters_card.dart';
import '../../widgets/barber/summary/summary_grid.dart';
import '../../widgets/barber/summary/summary_insights_section.dart';
import '../../widgets/barber/summary/summary_intro_card.dart';
import '../../widgets/barber/summary/summary_mini_strip.dart';
import '../../widgets/shared/app_date_picker_sheet.dart';

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
    controller.loadSummary();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickSpecificDate() async {
    final DateTime now = DateTime.now();
    final DateTime minDate = DateTime(now.year - 2, 1, 1);
    final DateTime maxDate = DateTime(now.year + 1, 12, 31);

    final DateTime? pickedDate = await showAppDatePickerSheet(
      context: context,
      initialDate: controller.selectedSpecificDate ?? now,
      title: 'اختر التاريخ',
      subtitle: 'اختر الشهر واليوم بالسحب',
      minSelectableDate: minDate,
      maxSelectableDate: maxDate,
    );

    if (pickedDate == null) return;

    await controller.selectSpecificDate(pickedDate);
  }

  Future<void> _handleFilterSelect(int index) async {
    if (index == 3) {
      await _pickSpecificDate();
      return;
    }

    await controller.selectFilter(index);
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

                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 42),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: controller.loadSummary,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                else ...[
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
              ],
            ),
          ),
        );
      },
    );
  }
}
