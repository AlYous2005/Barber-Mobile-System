//

import 'package:flutter/material.dart';

import '../../controllers/barber/barber_working_hours_controller.dart';
import '../../models/working_day_model.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';
import '../../widgets/barber/working_hours/working_day_card.dart';
import '../../widgets/barber/working_hours/working_hours_edit_sheet.dart';
import '../../widgets/barber/working_hours/working_hours_intro_card.dart';

class BarberWorkingHoursScreen extends StatefulWidget {
  const BarberWorkingHoursScreen({super.key});

  @override
  State<BarberWorkingHoursScreen> createState() =>
      _BarberWorkingHoursScreenState();
}

class _BarberWorkingHoursScreenState extends State<BarberWorkingHoursScreen> {
  late final BarberWorkingHoursController controller;

  @override
  void initState() {
    super.initState();

    controller = BarberWorkingHoursController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openEditSheet(WorkingDay day) {
    showModalBottomSheet<WorkingDay?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WorkingHoursEditSheet(day: day);
      },
    ).then((updatedDay) {
      if (!mounted || updatedDay == null) return;

      controller.updateWorkingDay(updatedDay);
      _showWorkingHoursSavedPopup();
    });
  }

  Future<void> _showWorkingHoursSavedPopup() async {
    if (!mounted) return;

    await showBarberFeedbackPopup(
      context: context,
      title: 'تم تحديث ساعات العمل',
      message: 'تم حفظ تغييرات اليوم بنجاح',
      icon: Icons.schedule_rounded,
      iconStartColor: const Color(0xFF16A34A),
      iconEndColor: const Color(0xFF86EFAC),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
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
                const WorkingHoursIntroCard(),

                const SizedBox(height: 16),

                ...controller.workingDays.map(
                  (day) => WorkingDayCard(
                    day: day,
                    formatTime: controller.formatTime,
                    onEdit: () => _openEditSheet(day),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
