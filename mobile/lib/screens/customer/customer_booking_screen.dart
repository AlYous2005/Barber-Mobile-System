import 'package:flutter/material.dart';

import '../../models/barber_model.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';

import '../../widgets/customer/booking/booking_date_selector.dart';
import '../../widgets/customer/booking/booking_summary_card.dart';
import '../../utils/booking_date_helpers.dart';
import '../../utils/booking_formatters.dart';
import '../../widgets/customer/booking/booking_step_header.dart';
import '../../widgets/customer/booking/booking_confirm_warning_card.dart';
import '../../widgets/customer/booking/choose_barber_step.dart';
import '../../widgets/customer/booking/choose_services_step.dart';
import '../../widgets/customer/booking/services_live_counter.dart';
import '../../widgets/customer/booking/available_times_step.dart';
import '../../widgets/customer/booking/booking_bottom_action_button.dart';
import '../../utils/app_theme_colors.dart';

import 'booking_success_screen.dart';

class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({super.key, this.preselectedBarber});

  final BarberModel? preselectedBarber;

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  int step = 0;

  BarberModel? selectedBarber;
  List<ServiceModel> selectedServices = [];
  BookingDateChoice dateChoice = BookingDateChoice.today;
  DateTime? customDate;
  String? selectedTime;

  @override
  void initState() {
    super.initState();

    if (widget.preselectedBarber != null) {
      selectedBarber = widget.preselectedBarber;
      step = 1;
    }
  }

  int get selectedTotalPrice {
    return selectedServices.fold(0, (sum, service) => sum + service.price);
  }

  int get selectedTotalDuration {
    return selectedServices.fold(
      0,
      (sum, service) => sum + service.durationMinutes,
    );
  }

  ServiceModel get combinedSelectedService {
    return ServiceModel(
      id: selectedServices.map((service) => service.id).join('+'),
      name: selectedServices.map((service) => service.name).join(' + '),
      durationMinutes: selectedTotalDuration,
      price: selectedTotalPrice,
    );
  }

  bool _isServiceSelected(ServiceModel service) {
    return selectedServices.any((item) => item.id == service.id);
  }

  void _toggleService(ServiceModel service) {
    setState(() {
      final bool alreadySelected = _isServiceSelected(service);

      if (alreadySelected) {
        selectedServices = selectedServices
            .where((item) => item.id != service.id)
            .toList();
      } else {
        selectedServices = [...selectedServices, service];
      }

      selectedTime = null;
    });
  }

  bool get _canGoNext {
    switch (step) {
      case 0:
        return selectedBarber != null;
      case 1:
        return selectedServices.isNotEmpty;
      case 2:
        if (dateChoice == BookingDateChoice.custom && customDate == null) {
          return false;
        }
        return true;
      case 3:
        return selectedTime != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _next() {
    if (!_canGoNext) return;
    if (step < 4) {
      setState(() => step += 1);
    }
  }

  void _back() {
    if (step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => step -= 1);
  }

  void _confirm() {
    final barber = selectedBarber!;
    final service = combinedSelectedService;
    final resolved = resolveBookingDate(dateChoice, customDate);
    final dateLabel = resolveDateDisplayLabel(dateChoice, resolved);
    final time = selectedTime!;

    final booking = BookingModel(
      barber: barber,
      service: service,
      date: resolved,
      timeLabel: time,
      price: service.price,
      dateDisplayLabel: dateLabel,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(booking: booking),
      ),
    );
  }

  String get _stepTitle {
    switch (step) {
      case 0:
        return 'اختر الحلاق';
      case 1:
        return 'اختر الخدمة';
      case 2:
        return 'اختر التاريخ';
      case 3:
        return 'الأوقات المتاحة';
      case 4:
        return 'تأكيد الحجز';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBg = Theme.of(context).scaffoldBackgroundColor;
    final Color titleColor = AppThemeColors.textPrimary(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          title: Text(
            'حجز موعد',
            style: TextStyle(color: titleColor, fontWeight: FontWeight.w900),
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
              child: BookingStepHeader(step: step, title: _stepTitle),
            ),

            if (step == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ServicesLiveCounter(
                  totalPrice: selectedTotalPrice,
                  totalDuration: selectedTotalDuration,
                  selectedCount: selectedServices.length,
                ),
              ),

            if (step == 4)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: BookingConfirmWarningCard(),
              ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (step == 0 && selectedBarber != null) {
                    setState(() {
                      selectedBarber = null;
                      selectedServices = [];
                      selectedTime = null;
                    });
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
                isConfirmStep: step == 4,
                canContinue: _canGoNext,
                onPressed: step == 4 ? _confirm : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (step) {
      case 0:
        return ChooseBarberStep(
          selectedBarber: selectedBarber,
          onSelectBarber: (barber) {
            setState(() {
              selectedBarber = barber;
              selectedServices = [];
              selectedTime = null;
            });
          },
        );
      case 1:
        return ChooseServicesStep(
          selectedServices: selectedServices,
          onToggleService: _toggleService,
        );
      case 2:
        return BookingDateSelector(
          choice: dateChoice,
          customDate: customDate,
          onChoiceChanged: (c) {
            setState(() {
              dateChoice = c;
              selectedTime = null;

              if (c != BookingDateChoice.custom) {
                customDate = null;
              }
            });
          },
          onCustomDateChanged: (date) {
            setState(() {
              customDate = date;
              dateChoice = BookingDateChoice.custom;
              selectedTime = null;
            });
          },
        );
      case 3:
        final DateTime resolvedDate = resolveBookingDate(
          dateChoice,
          customDate,
        );

        return AvailableTimesStep(
          selectedTime: selectedTime,
          selectedDateLabel: dateWithDayLabel(resolvedDate),
          requiredDurationLabel: formatBookingDuration(selectedTotalDuration),
          onSelectTime: (time) {
            setState(() {
              selectedTime = time;
            });
          },
        );
      case 4:
        final barber = selectedBarber!;
        final resolvedDate = resolveBookingDate(dateChoice, customDate);

        return BookingSummaryCard(
          barberName: barber.name,
          barberLocation: 'زيتا، زيتا',
          selectedServices: selectedServices,
          dateLabel: dateWithDayLabel(resolvedDate),
          timeLabel: selectedTime!,
          totalPrice: selectedTotalPrice,
          totalDurationLabel: formatBookingDuration(selectedTotalDuration),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
