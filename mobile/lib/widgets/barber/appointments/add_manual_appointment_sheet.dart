import 'package:flutter/material.dart';

import '../../../services/auth_session.dart';
import '../../../general_utils/app_theme_colors.dart';
import '../../../features/barber/services_management/services_management.dart';
import '../../shared/app_date_picker_sheet.dart';
import 'manual_appointment_widgets.dart';
import '../../../features/barber/schedule/schedule.dart';
import '../../../features/bookings/bookings.dart';

typedef AddManualAppointmentCallback =
    Future<void> Function({
      required String customerName,
      required List<ServiceModel> services,
      required DateTime startDateTime,
    });

class AddManualAppointmentSheet extends StatefulWidget {
  const AddManualAppointmentSheet({
    super.key,
    required this.onAddAppointment,
    required this.onAddedSuccessfully,
    required this.onMessage,
  });

  final AddManualAppointmentCallback onAddAppointment;
  final VoidCallback onAddedSuccessfully;
  final ValueChanged<String> onMessage;

  @override
  State<AddManualAppointmentSheet> createState() =>
      _AddManualAppointmentSheetState();
}

class _AddManualAppointmentSheetState extends State<AddManualAppointmentSheet> {
  late final TextEditingController customerNameController;
  final ServiceRepository serviceRepository = const ServiceRepository();

  final BarberWorkingHoursRepository workingHoursRepository =
      const BarberWorkingHoursRepository();
  final BarberAvailabilityRepository availabilityRepository =
      const BarberAvailabilityRepository();
  final BookingRepository bookingRepository = const BookingRepository();

  List<ServiceModel> availableServices = [];
  bool isLoadingServices = true;
  String? servicesLoadError;

  List<ServiceModel> selectedServices = [];
  ServiceTarget? activeServiceTarget = ServiceTarget.personal;
  ManualAppointmentDateChoice selectedDateChoice =
      ManualAppointmentDateChoice.today;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<DateTime> availableTimeSlots = [];
  bool isLoadingTimeSlots = false;
  String? timeSlotsMessage;
  int _timeSlotsRequestId = 0;
  bool isSubmittingAppointment = false;
  String? customerNameError;
  String? serviceError;
  String? dateError;
  String? timeError;

  int customerNameShakeTrigger = 0;
  int serviceShakeTrigger = 0;
  int dateShakeTrigger = 0;
  int timeShakeTrigger = 0;

  late final FocusNode customerNameFocusNode;

  int get _selectedTotalDuration {
    return selectedServices.fold(
      0,
      (sum, service) => sum + service.durationMinutes,
    );
  }

  @override
  void initState() {
    super.initState();
    customerNameController = TextEditingController();
    customerNameFocusNode = FocusNode();
    _loadAvailableServices();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableServices() async {
    final String? barberId = AuthSession.currentUser?.barberId;

    if (barberId == null || barberId.trim().isEmpty) {
      if (!mounted) return;

      setState(() {
        isLoadingServices = false;
        servicesLoadError = 'تعذر معرفة حساب الحلاق الحالي';
      });

      return;
    }

    try {
      final services = await serviceRepository.getAvailableServices(
        barberId: barberId,
      );

      if (!mounted) return;

      setState(() {
        availableServices = services;
        isLoadingServices = false;
        servicesLoadError = services.isEmpty
            ? 'لا توجد خدمات مفعّلة حاليًا'
            : null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingServices = false;
        servicesLoadError = 'تعذر تحميل الخدمات';
      });
    }
  }

  String _emptySlotsMessage() {
    switch (selectedDateChoice) {
      case ManualAppointmentDateChoice.today:
        return 'لا توجد أوقات متاحة اليوم';
      case ManualAppointmentDateChoice.tomorrow:
        return 'لا توجد أوقات متاحة للغد';
      case ManualAppointmentDateChoice.custom:
        return 'لا توجد أوقات متاحة لهذا التاريخ';
    }
  }

  DateTime? _resolvedAppointmentDate() {
    final DateTime now = DateTime.now();

    switch (selectedDateChoice) {
      case ManualAppointmentDateChoice.today:
        return DateTime(now.year, now.month, now.day);

      case ManualAppointmentDateChoice.tomorrow:
        final DateTime tomorrow = now.add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      case ManualAppointmentDateChoice.custom:
        if (selectedDate == null) {
          return null;
        }

        return DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
        );
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    final int requestId = ++_timeSlotsRequestId;

    final String? barberId = AuthSession.currentUser?.barberId;
    final DateTime? appointmentDate = _resolvedAppointmentDate();

    if (barberId == null || barberId.trim().isEmpty) {
      if (!mounted) return;

      setState(() {
        availableTimeSlots = [];
        selectedTime = null;
        timeSlotsMessage = 'تعذر معرفة حساب الحلاق الحالي';
      });

      return;
    }

    if (appointmentDate == null) {
      if (!mounted) return;

      setState(() {
        availableTimeSlots = [];
        selectedTime = null;
        timeSlotsMessage = 'اختر تاريخ الموعد أولًا';
      });

      return;
    }

    if (_selectedTotalDuration <= 0) {
      if (!mounted) return;

      setState(() {
        availableTimeSlots = [];
        selectedTime = null;
        timeSlotsMessage = 'اختر خدمة واحدة على الأقل لعرض الأوقات المتاحة';
      });

      return;
    }

    setState(() {
      isLoadingTimeSlots = true;
      availableTimeSlots = [];
      selectedTime = null;
      timeSlotsMessage = null;
    });

    try {
      final workingDays = await workingHoursRepository.getWorkingDays(
        barberId: barberId,
      );

      final closures = await availabilityRepository.getClosures(
        barberId: barberId,
      );

      final timeBlocks = await availabilityRepository.getTimeBlocks(
        barberId: barberId,
      );

      final appointments = await bookingRepository.getBarberAppointmentsForDate(
        barberId: barberId,
        date: appointmentDate,
      );

      final slots = ManualAppointmentSlotsHelper.buildAvailableSlots(
        date: appointmentDate,
        totalDurationMinutes: _selectedTotalDuration,
        workingDays: workingDays,
        existingAppointments: appointments,
        closures: closures,
        timeBlocks: timeBlocks,
        stepMinutes: 15,
      );
      debugPrint('MANUAL_SLOTS_DEBUG: date = $appointmentDate');
      debugPrint('MANUAL_SLOTS_DEBUG: totalDuration = $_selectedTotalDuration');
      debugPrint(
        'MANUAL_SLOTS_DEBUG: workingDays = ${workingDays.map((d) => '${d.dayName}/${d.dayOfWeek}/${d.startTime}-${d.endTime}/active=${d.isActive}').toList()}',
      );
      debugPrint(
        'MANUAL_SLOTS_DEBUG: appointments count = ${appointments.length}',
      );
      debugPrint(
        'MANUAL_SLOTS_DEBUG: closures = ${closures.map((c) => '${c.dateLabel} - ${c.reason}').toList()}',
      );
      debugPrint(
        'MANUAL_SLOTS_DEBUG: timeBlocks = ${timeBlocks.map((b) => 'type=${b.type}, date=${b.dateLabel}, ${b.startTime}-${b.endTime}, reason=${b.reason}').toList()}',
      );
      debugPrint('MANUAL_SLOTS_DEBUG: slots count = ${slots.length}');

      if (!mounted || requestId != _timeSlotsRequestId) return;

      setState(() {
        availableTimeSlots = slots;
        isLoadingTimeSlots = false;
        timeSlotsMessage = slots.isEmpty ? _emptySlotsMessage() : null;
      });
    } catch (error, stackTrace) {
      debugPrint('LOAD_MANUAL_TIME_SLOTS_ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || requestId != _timeSlotsRequestId) return;

      setState(() {
        availableTimeSlots = [];
        isLoadingTimeSlots = false;
        timeSlotsMessage = 'تعذر تحميل الأوقات المتاحة';
      });
    }
  }

  Future<void> _selectDateChoice(ManualAppointmentDateChoice choice) async {
    if (choice == ManualAppointmentDateChoice.custom) {
      await _pickDate();
      await _loadAvailableTimeSlots();
      return;
    }

    setState(() {
      selectedDateChoice = choice;
      selectedDate = null;
      dateError = null;
    });

    await _loadAvailableTimeSlots();
  }

  void _toggleService(ServiceModel service) {
    final bool isSelected = selectedServices.any(
      (item) => item.id == service.id,
    );

    setState(() {
      if (isSelected) {
        selectedServices = selectedServices
            .where((item) => item.id != service.id)
            .toList();
      } else {
        selectedServices = [...selectedServices, service];
      }

      serviceError = null;
    });

    _loadAvailableTimeSlots();
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showAppDatePickerSheet(
      context: context,
      initialDate: selectedDate,
      title: 'اختر تاريخ الموعد',
      subtitle: 'اختر الشهر واليوم بالسحب',
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDateChoice = ManualAppointmentDateChoice.custom;
      selectedDate = pickedDate;
      dateError = null;
    });

    await _loadAvailableTimeSlots();
  }

  void _selectTimeSlot(DateTime slot) {
    setState(() {
      selectedTime = TimeOfDay.fromDateTime(slot);
      timeError = null;
    });
  }

  bool _validateForm() {
    bool isValid = true;
    bool shouldFocusCustomerName = false;

    setState(() {
      customerNameError = null;
      serviceError = null;
      dateError = null;
      timeError = null;

      final String customerName = customerNameController.text.trim();

      if (customerName.isEmpty) {
        customerNameError = 'الرجاء إدخال اسم الزبون';
        customerNameShakeTrigger++;
        isValid = false;
        shouldFocusCustomerName = true;
      }

      if (selectedServices.isEmpty) {
        serviceError = 'الرجاء اختيار خدمة واحدة على الأقل';
        serviceShakeTrigger++;
        isValid = false;
      }

      if (_resolvedAppointmentDate() == null) {
        dateError = 'الرجاء اختيار تاريخ الموعد';
        dateShakeTrigger++;
        isValid = false;
      }

      if (selectedTime == null) {
        timeError = 'الرجاء اختيار وقت الموعد';
        timeShakeTrigger++;
        isValid = false;
      }
    });

    if (shouldFocusCustomerName) {
      customerNameFocusNode.requestFocus();
    }

    return isValid;
  }

  Future<void> _addManualAppointment() async {
    if (isSubmittingAppointment) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    setState(() {
      isSubmittingAppointment = true;
    });

    try {
      final String customerName = customerNameController.text.trim();

      final DateTime appointmentDate = _resolvedAppointmentDate()!;

      final DateTime startDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await widget.onAddAppointment(
        customerName: customerName,
        services: selectedServices,
        startDateTime: startDateTime,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onAddedSuccessfully();
    } catch (error, stackTrace) {
      debugPrint('ADD_MANUAL_APPOINTMENT_ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      widget.onMessage('حدث خطأ أثناء إضافة الموعد');
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingAppointment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: AppThemeColors.card(context),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppThemeColors.border(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(
                            0xFFC47A3D,
                          ).withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.add_task_rounded,
                        color: Color(0xFFC47A3D),
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'إضافة موعد يدوي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                    ),

                    Material(
                      color: AppThemeColors.softCard(context),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.close_rounded,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                ManualAppointmentTextField(
                  label: 'اسم الزبون',
                  hint: 'مثال: أحمد خالد',
                  icon: Icons.person_rounded,
                  controller: customerNameController,
                  focusNode: customerNameFocusNode,
                  errorText: customerNameError,
                  hasError: customerNameError != null,
                  shakeTrigger: customerNameShakeTrigger,
                ),

                const SizedBox(height: 14),

                ManualServicesSelector(
                  services: availableServices,
                  selectedServices: selectedServices,
                  activeTarget: activeServiceTarget,
                  isLoadingServices: isLoadingServices,
                  loadErrorText: servicesLoadError,
                  errorText: serviceError,
                  hasError: serviceError != null,
                  shakeTrigger: serviceShakeTrigger,
                  onTargetChanged: (target) {
                    setState(() {
                      activeServiceTarget = target;
                    });
                  },
                  onToggleService: _toggleService,
                ),

                const SizedBox(height: 14),

                ManualDateChoiceSelector(
                  selectedChoice: selectedDateChoice,
                  customDate: selectedDate,
                  errorText: dateError,
                  hasError: dateError != null,
                  shakeTrigger: dateShakeTrigger,
                  onChoiceSelected: (choice) {
                    _selectDateChoice(choice);
                  },
                ),

                const SizedBox(height: 14),

                ManualAvailableTimeSlotsSelector(
                  slots: availableTimeSlots,
                  selectedTime: selectedTime,
                  isLoading: isLoadingTimeSlots,
                  message: timeSlotsMessage,
                  errorText: timeError,
                  hasError: timeError != null,
                  shakeTrigger: timeShakeTrigger,
                  onSelectSlot: _selectTimeSlot,
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoadingServices || isSubmittingAppointment
                        ? null
                        : _addManualAppointment,
                    icon: isSubmittingAppointment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(
                      isSubmittingAppointment
                          ? 'جاري الإضافة...'
                          : 'إضافة الموعد',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC47A3D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
