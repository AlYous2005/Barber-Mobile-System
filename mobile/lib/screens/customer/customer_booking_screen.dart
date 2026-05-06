import 'package:flutter/material.dart';

import '../../controllers/customer/customer_booking_controller.dart';
import '../../models/barber_model.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/booking_date_helpers.dart';
import '../../utils/booking_formatters.dart';
import '../../widgets/customer/booking/available_times_step.dart';
import '../../widgets/customer/booking/booking_bottom_action_button.dart';
import '../../widgets/customer/booking/booking_confirm_warning_card.dart';
import '../../widgets/customer/booking/booking_date_selector.dart';
import '../../widgets/customer/booking/booking_step_header.dart';
import '../../widgets/customer/booking/booking_summary_card.dart';
import '../../widgets/customer/booking/choose_barber_step.dart';
import '../../widgets/customer/booking/choose_services_step.dart';
import '../../widgets/customer/booking/services_live_counter.dart';
import 'booking_success_screen.dart';

class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({super.key, this.preselectedBarber});

  final BarberModel? preselectedBarber;

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  late final CustomerBookingController controller;

  @override
  void initState() {
    super.initState();

    controller = CustomerBookingController(
      preselectedBarber: widget.preselectedBarber,
    );

    controller.loadBookingData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _back() {
    if (controller.step == 0) {
      Navigator.of(context).pop();
      return;
    }

    controller.goBack();
  }

  Future<void> _confirm() async {
    try {
      final createdBooking = await controller.confirmBooking();

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BookingSuccessScreen(booking: createdBooking),
        ),
      );
    } on CustomerBookingControllerException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final Color pageBg = Theme.of(context).scaffoldBackgroundColor;
        final Color titleColor = AppThemeColors.textPrimary(context);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: pageBg,
            appBar: AppBar(
              title: Text(
                'حجز موعد',
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              centerTitle: true,
              backgroundColor: pageBg,
              surfaceTintColor: pageBg,
              leading: IconButton(
                onPressed: _back,
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                  child: BookingStepHeader(
                    step: controller.step,
                    title: controller.stepTitle,
                  ),
                ),

                if (controller.step == 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: ServicesLiveCounter(
                      totalPrice: controller.selectedTotalPrice,
                      totalDuration: controller.selectedTotalDuration,
                      selectedCount: controller.selectedServices.length,
                    ),
                  ),

                if (controller.step == 4)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: BookingConfirmWarningCard(),
                  ),

                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (controller.step == 0 &&
                          controller.selectedBarber != null) {
                        controller.clearSelectedBarber();
                      }
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: _buildStepBody(),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: BookingBottomActionButton(
                    isConfirmStep: controller.step == 4,
                    canContinue:
                        controller.canGoNext && !controller.isCreatingBooking,
                    onPressed: controller.step == 4
                        ? _confirm
                        : controller.goNext,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepBody() {
    if (controller.isLoadingData) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.dataErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: [
              const Icon(Icons.error_outline_rounded, size: 42),
              const SizedBox(height: 12),
              Text(
                controller.dataErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: controller.loadBookingData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    switch (controller.step) {
      case 0:
        return ChooseBarberStep(
          barbers: controller.availableBarbers,
          selectedBarber: controller.selectedBarber,
          onSelectBarber: controller.selectBarber,
        );

      case 1:
        return ChooseServicesStep(
          services: controller.availableServices,
          selectedServices: controller.selectedServices,
          onToggleService: controller.toggleService,
        );

      case 2:
        return BookingDateSelector(
          choice: controller.dateChoice,
          customDate: controller.customDate,
          onChoiceChanged: controller.changeDateChoice,
          onCustomDateChanged: controller.changeCustomDate,
        );

      case 3:
        final DateTime resolvedDate = resolveBookingDate(
          controller.dateChoice,
          controller.customDate,
        );

        return AvailableTimesStep(
          selectedTime: controller.selectedTime,
          selectedDateLabel: dateWithDayLabel(resolvedDate),
          requiredDurationLabel: formatBookingDuration(
            controller.selectedTotalDuration,
          ),
          onSelectTime: controller.selectTime,
        );

      case 4:
        final barber = controller.selectedBarber!;
        final resolvedDate = resolveBookingDate(
          controller.dateChoice,
          controller.customDate,
        );

        return BookingSummaryCard(
          barberName: barber.name,
          barberLocation: 'زيتا، زيتا',
          selectedServices: controller.selectedServices,
          dateLabel: dateWithDayLabel(resolvedDate),
          timeLabel: controller.selectedTime!,
          totalPrice: controller.selectedTotalPrice,
          totalDurationLabel: formatBookingDuration(
            controller.selectedTotalDuration,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
