import 'package:flutter/material.dart';

import '../../../models/mock_appointment.dart';
import '../../../models/mock_service.dart';
import '../../../utils/app_theme_colors.dart';
import 'manual_appointment_widgets.dart';

class AddManualAppointmentSheet extends StatefulWidget {
  const AddManualAppointmentSheet({
    super.key,
    required this.onAddAppointment,
    required this.onAddedSuccessfully,
    required this.onMessage,
  });

  final ValueChanged<MockAppointment> onAddAppointment;
  final VoidCallback onAddedSuccessfully;
  final ValueChanged<String> onMessage;

  @override
  State<AddManualAppointmentSheet> createState() =>
      _AddManualAppointmentSheetState();
}

class _AddManualAppointmentSheetState extends State<AddManualAppointmentSheet> {
  late final TextEditingController customerNameController;

  String? selectedServiceName;
  int selectedServiceDuration = 30;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? customerNameError;
  String? serviceError;
  String? dateError;
  String? timeError;

  int customerNameShakeTrigger = 0;
  int serviceShakeTrigger = 0;
  int dateShakeTrigger = 0;
  int timeShakeTrigger = 0;

  late final FocusNode customerNameFocusNode;

  @override
  void initState() {
    super.initState();
    customerNameController = TextEditingController();
    customerNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      selectedDate = pickedDate;
      dateError = null;
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedTime = pickedTime;
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

      if (selectedServiceName == null) {
        serviceError = 'الرجاء اختيار نوع الخدمة';
        serviceShakeTrigger++;
        isValid = false;
      }

      if (selectedDate == null) {
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

  void _addManualAppointment() {
    if (!_validateForm()) {
      return;
    }
    try {
      final String customerName = customerNameController.text.trim();

      final DateTime startDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final DateTime endDateTime = startDateTime.add(
        Duration(minutes: selectedServiceDuration),
      );

      final String dateLabel = _dateLabelFor(selectedDate!);
      final String timeLabel =
          '${_formatTimeOfDay(selectedTime!)} - ${_formatDateTimeTime(endDateTime)}';

      final appointment = MockAppointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: customerName,
        barberName: 'أنت',
        barberRating: 0,
        serviceName: selectedServiceName!,
        dateLabel: dateLabel,
        timeLabel: timeLabel,
        status: 'مؤكد',
        startDateTime: startDateTime,
        endDateTime: endDateTime,
      );

      widget.onAddAppointment(appointment);
      Navigator.of(context).pop();
      widget.onAddedSuccessfully();
    } catch (_) {
      widget.onMessage('حدث خطأ أثناء إضافة الموعد');
    }
  }

  String _dateLabelFor(DateTime date) {
    final DateTime now = DateTime.now();

    final bool isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) return 'اليوم';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

    return '$hour:$minute $period';
  }

  String _formatDateTimeTime(DateTime dateTime) {
    final TimeOfDay time = TimeOfDay.fromDateTime(dateTime);
    return _formatTimeOfDay(time);
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
                ManualServiceDropdown(
                  selectedServiceName: selectedServiceName,
                  errorText: serviceError,
                  hasError: serviceError != null,
                  shakeTrigger: serviceShakeTrigger,
                  onChanged: (value) {
                    if (value == null) return;

                    final service = mockBarberServices.firstWhere(
                      (item) => item.name == value,
                    );

                    setState(() {
                      selectedServiceName = value;
                      selectedServiceDuration =
                          int.tryParse(service.durationMinutes.toString()) ??
                          30;
                      serviceError = null;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PickerBox(
                        label: 'تاريخ الموعد',
                        value: selectedDate == null
                            ? 'اختر التاريخ'
                            : _dateLabelFor(selectedDate!),
                        icon: Icons.calendar_month_rounded,
                        onTap: _pickDate,
                        errorText: dateError,
                        hasError: dateError != null,
                        shakeTrigger: dateShakeTrigger,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PickerBox(
                        label: 'وقت الموعد',
                        value: selectedTime == null
                            ? 'اختر الوقت'
                            : _formatTimeOfDay(selectedTime!),
                        icon: Icons.access_time_rounded,
                        onTap: _pickTime,
                        errorText: timeError,
                        hasError: timeError != null,
                        shakeTrigger: timeShakeTrigger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemeColors.elevatedCard(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppThemeColors.border(context)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: Color(0xFFC47A3D),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'مدة الموعد ستُحسب تلقائيًا حسب الخدمة المختارة: $selectedServiceDuration دقيقة',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            color: AppThemeColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ManualPrimaryButton(
                    label: 'إضافة الموعد',
                    icon: Icons.add_rounded,
                    onTap: _addManualAppointment,
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
