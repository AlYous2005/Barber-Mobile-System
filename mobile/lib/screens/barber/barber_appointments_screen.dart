import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../models/mock_service.dart';

class BarberAppointmentsScreen extends StatefulWidget {
  const BarberAppointmentsScreen({super.key});

  @override
  State<BarberAppointmentsScreen> createState() =>
      _BarberAppointmentsScreenState();
}

class _BarberAppointmentsScreenState extends State<BarberAppointmentsScreen> {
  late List<MockAppointment> appointments;

  String selectedTab = 'today';

  @override
  void initState() {
    super.initState();
    appointments = List<MockAppointment>.from(mockBarberAppointments);
  }

  List<MockAppointment> get todayAppointments {
    return appointments.where((appointment) {
      return appointment.dateLabel.contains('اليوم');
    }).toList();
  }

  List<MockAppointment> get otherAppointments {
    return appointments.where((appointment) {
      return !appointment.dateLabel.contains('اليوم');
    }).toList();
  }

  List<MockAppointment> get activeAppointments {
    return selectedTab == 'today' ? todayAppointments : otherAppointments;
  }

  String get activeListTitle {
    return selectedTab == 'today' ? 'مواعيد اليوم' : 'حجوزات أخرى';
  }

  String get activeEmptyText {
    return selectedTab == 'today'
        ? 'لا توجد مواعيد اليوم حاليًا'
        : 'لا توجد حجوزات أخرى حاليًا';
  }

  void _updateStatus(String id, String status) {
    setState(() {
      appointments = appointments
          .map(
            (item) => item.id == id
                ? MockAppointment(
                    id: item.id,
                    customerName: item.customerName,
                    barberName: item.barberName,
                    barberRating: item.barberRating,
                    serviceName: item.serviceName,
                    dateLabel: item.dateLabel,
                    timeLabel: item.timeLabel,
                    status: status,
                    startDateTime: item.startDateTime,
                    endDateTime: item.endDateTime,
                  )
                : item,
          )
          .toList();
    });
  }

  void _openAddManualAppointmentSheet() {
    final TextEditingController customerNameController =
        TextEditingController();

    String? selectedServiceName;
    int selectedServiceDuration = 30;

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDate() async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (pickedDate == null) return;

              setSheetState(() {
                selectedDate = pickedDate;
              });
            }

            Future<void> pickTime() async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );

              if (pickedTime == null) return;

              setSheetState(() {
                selectedTime = pickedTime;
              });
            }

            void addManualAppointment() {
              final String customerName = customerNameController.text.trim();

              if (customerName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إدخال اسم الزبون'),
                  ),
                );
                return;
              }

              if (selectedServiceName == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى اختيار نوع الخدمة'),
                  ),
                );
                return;
              }

              final DateTime startDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              final DateTime endDateTime = startDateTime.add(
                Duration(minutes: selectedServiceDuration),
              );

              final String dateLabel = _dateLabelFor(selectedDate);
              final String timeLabel =
                  '${_formatTimeOfDay(selectedTime)} - ${_formatDateTimeTime(endDateTime)}';

              setState(() {
                appointments.insert(
                  0,
                  MockAppointment(
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
                  ),
                );
              });

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة الموعد اليدوي بنجاح'),
                ),
              );
            }

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
                    color: Colors.white,
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
                            color: const Color(0xFFE5E7EB),
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
                                color: const Color(0xFFC47A3D)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFC47A3D)
                                      .withValues(alpha: 0.18),
                                ),
                              ),
                              child: const Icon(
                                Icons.add_task_rounded,
                                color: Color(0xFFC47A3D),
                                size: 21,
                              ),
                            ),

                            const SizedBox(width: 10),

                            const Expanded(
                              child: Text(
                                'إضافة موعد يدوي',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),

                            Material(
                              color: const Color(0xFFF5F5F4),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.of(context).pop(),
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        _ManualAppointmentTextField(
                          label: 'اسم الزبون',
                          hint: 'مثال: أحمد خالد',
                          icon: Icons.person_rounded,
                          controller: customerNameController,
                        ),

                        const SizedBox(height: 14),

                        _ManualServiceDropdown(
                          selectedServiceName: selectedServiceName,
                          onChanged: (value) {
                            if (value == null) return;

                            final service = mockBarberServices.firstWhere(
                              (item) => item.name == value,
                            );

                            setSheetState(() {
                              selectedServiceName = value;
                              selectedServiceDuration = int.tryParse(
                                    service.durationMinutes.toString(),
                                  ) ??
                                  30;
                            });
                          },
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _PickerBox(
                                label: 'تاريخ الموعد',
                                value: _dateLabelFor(selectedDate),
                                icon: Icons.calendar_month_rounded,
                                onTap: pickDate,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PickerBox(
                                label: 'وقت الموعد',
                                value: _formatTimeOfDay(selectedTime),
                                icon: Icons.access_time_rounded,
                                onTap: pickTime,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBF2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE8D8B8),
                            ),
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
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6B4F3E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: _ManualPrimaryButton(
                            label: 'إضافة الموعد',
                            icon: Icons.add_rounded,
                            onTap: addManualAppointment,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      customerNameController.dispose();
    });
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

  void _confirmStatusChange({
    required MockAppointment appointment,
    required String newStatus,
    required String title,
    required String message,
    required String confirmText,
    required Color color,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: _AppointmentActionButton(
                      label: confirmText,
                      icon: Icons.check_rounded,
                      color: color,
                      onTap: () {
                        Navigator.of(context).pop();
                        _updateStatus(appointment.id, newStatus);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: _SecondaryButton(
                      label: 'إلغاء',
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleConfirmAppointment(MockAppointment appointment) {
    _confirmStatusChange(
      appointment: appointment,
      newStatus: 'مؤكد',
      title: 'تأكيد الموعد',
      message: 'هل تريد تأكيد موعد الزبون "${appointment.customerName}"؟',
      confirmText: 'تأكيد',
      color: const Color(0xFF3D7A5C),
    );
  }

  void _handleCheckIn(MockAppointment appointment) {
    _confirmStatusChange(
      appointment: appointment,
      newStatus: 'مكتمل',
      title: 'تسجيل حضور الزبون',
      message: 'هل تريد تسجيل حضور "${appointment.customerName}" وإنهاء الموعد؟',
      confirmText: 'تسجيل حضور',
      color: const Color(0xFF4A6FA8),
    );
  }

  void _handleNoShow(MockAppointment appointment) {
    _confirmStatusChange(
      appointment: appointment,
      newStatus: 'لم يحضر',
      title: 'تسجيل عدم حضور',
      message: 'هل تريد تسجيل أن الزبون "${appointment.customerName}" لم يحضر؟',
      confirmText: 'عدم حضور',
      color: const Color(0xFFC2783A),
    );
  }

  void _handleCancel(MockAppointment appointment) {
    _confirmStatusChange(
      appointment: appointment,
      newStatus: 'ملغي',
      title: 'إلغاء الموعد',
      message: 'هل تريد إلغاء موعد الزبون "${appointment.customerName}"؟',
      confirmText: 'إلغاء الموعد',
      color: const Color(0xFFC9544A),
    );
  }

  bool _isFinalStatus(String status) {
    return status == 'مكتمل' ||
        status == 'مكتملة' ||
        status == 'ملغي' ||
        status == 'ملغية' ||
        status == 'لم يحضر';
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            const _AppointmentsSectionIntro(),

            const SizedBox(height: 14),

            _AddManualAppointmentButton(
              onTap: _openAddManualAppointmentSheet,
            ),

            const SizedBox(height: 14),

            _AppointmentsSubnav(
              selectedTab: selectedTab,
              onChanged: (value) {
                setState(() {
                  selectedTab = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _AppointmentsListSection(
              title: activeListTitle,
              emptyText: activeEmptyText,
              appointments: activeAppointments,
              isFinalStatus: _isFinalStatus,
              onConfirm: _handleConfirmAppointment,
              onCheckIn: _handleCheckIn,
              onNoShow: _handleNoShow,
              onCancel: _handleCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsSectionIntro extends StatelessWidget {
  const _AppointmentsSectionIntro();

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
          colors: [
            Color(0xFF6E3F2F),
            Color(0xFF9B5A3D),
            Color(0xFFC37A49),
          ],
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
          _AppointmentsCenterPill(),

          SizedBox(height: 14),

          Text(
            'المواعيد',
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
            'إدارة مواعيد اليوم والحجوزات الأخرى بسهولة',
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

class _AppointmentsCenterPill extends StatelessWidget {
  const _AppointmentsCenterPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Appointment Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.close_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddManualAppointmentButton extends StatelessWidget {
  const _AddManualAppointmentButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC47A3D),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9A5A38),
                Color(0xFFB8774A),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3020532D),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'إضافة موعد يدوي',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentsSubnav extends StatelessWidget {
  const _AppointmentsSubnav({
    required this.selectedTab,
    required this.onChanged,
  });

  final String selectedTab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8D8B8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SubnavButton(
              label: 'مواعيد اليوم',
              icon: Icons.calendar_today_rounded,
              isActive: selectedTab == 'today',
              onTap: () => onChanged('today'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SubnavButton(
              label: 'حجوزات أخرى',
              icon: Icons.date_range_rounded,
              isActive: selectedTab == 'other',
              onTap: () => onChanged('other'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubnavButton extends StatelessWidget {
  const _SubnavButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF8F4E2C);

    return Material(
      color: isActive ? activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x228F4E2C),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isActive ? Colors.white : const Color(0xFF6B5D52),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : const Color(0xFF6B5D52),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentsListSection extends StatelessWidget {
  const _AppointmentsListSection({
    required this.title,
    required this.emptyText,
    required this.appointments,
    required this.isFinalStatus,
    required this.onConfirm,
    required this.onCheckIn,
    required this.onNoShow,
    required this.onCancel,
  });

  final String title;
  final String emptyText;
  final List<MockAppointment> appointments;
  final bool Function(String status) isFinalStatus;
  final ValueChanged<MockAppointment> onConfirm;
  final ValueChanged<MockAppointment> onCheckIn;
  final ValueChanged<MockAppointment> onNoShow;
  final ValueChanged<MockAppointment> onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFDFCFA),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0x14744F40),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142C221C),
            blurRadius: 44,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFAF4EE),
                    Color(0xFFF6EEE6),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0x29B4825A),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14B8774A),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8F4E2C),
                          Color(0xFFB86A3D),
                          Color(0xFFA85C34),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x288F4E2C),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2A2018),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (appointments.isEmpty)
            _EmptyAppointmentsState(emptyText: emptyText)
          else
            ...appointments.map(
              (appointment) => _AppointmentLuxuryCard(
                appointment: appointment,
                isFinal: isFinalStatus(appointment.status),
                onConfirm: () => onConfirm(appointment),
                onCheckIn: () => onCheckIn(appointment),
                onNoShow: () => onNoShow(appointment),
                onCancel: () => onCancel(appointment),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyAppointmentsState extends StatelessWidget {
  const _EmptyAppointmentsState({
    required this.emptyText,
  });

  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFAF6F1),
            Color(0xFFF6F0E9),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0x22785A46),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFAECE0),
                  Color(0xFFF4E2D2),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF8A4A2A),
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'لا توجد مواعيد هنا الآن',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A2018),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  emptyText,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A7A72),
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

class _AppointmentLuxuryCard extends StatefulWidget {
  const _AppointmentLuxuryCard({
    required this.appointment,
    required this.isFinal,
    required this.onConfirm,
    required this.onCheckIn,
    required this.onNoShow,
    required this.onCancel,
  });

  final MockAppointment appointment;
  final bool isFinal;
  final VoidCallback onConfirm;
  final VoidCallback onCheckIn;
  final VoidCallback onNoShow;
  final VoidCallback onCancel;

  @override
  State<_AppointmentLuxuryCard> createState() => _AppointmentLuxuryCardState();
}

class _AppointmentLuxuryCardState extends State<_AppointmentLuxuryCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final MockAppointment appointment = widget.appointment;

    return AnimatedScale(
      scale: isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressed = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFCFA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0x1A4A3428),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(status: appointment.status),

              const SizedBox(height: 14),

              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAECE0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0x33C8A078),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF5C4030),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appointment.customerName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2A2018),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _AppointmentDetailLine(
                icon: Icons.content_cut_rounded,
                text: appointment.serviceName,
              ),

              const SizedBox(height: 10),

              _AppointmentDetailLine(
                icon: Icons.access_time_rounded,
                text: appointment.timeLabel,
              ),

              const SizedBox(height: 10),

              _AppointmentDetailLine(
                icon: Icons.calendar_month_rounded,
                text: appointment.dateLabel,
              ),

              if (!widget.isFinal) ...[
                const SizedBox(height: 16),
                _ActionsGrid(
                  onConfirm: widget.onConfirm,
                  onCheckIn: widget.onCheckIn,
                  onNoShow: widget.onNoShow,
                  onCancel: widget.onCancel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentDetailLine extends StatelessWidget {
  const _AppointmentDetailLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F2EC),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0x38C8AA8C),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6B4F3E),
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  String get label {
    switch (status) {
      case 'قادم':
        return 'محجوز';
      case 'مؤكد':
        return 'مؤكد';
      case 'مكتمل':
      case 'مكتملة':
        return 'منجز';
      case 'ملغي':
      case 'ملغية':
        return 'ملغي';
      case 'لم يحضر':
        return 'لم يحضر';
      case 'جاري':
        return 'جاري';
      default:
        return status;
    }
  }

  Color get textColor {
    switch (status) {
      case 'مؤكد':
        return const Color(0xFF1E4A36);
      case 'ملغي':
      case 'ملغية':
        return const Color(0xFF7A2E2A);
      case 'لم يحضر':
        return const Color(0xFF6B3D28);
      case 'مكتمل':
      case 'مكتملة':
        return const Color(0xFF2C4F78);
      default:
        return const Color(0xFF4C3D66);
    }
  }

  List<Color> get gradientColors {
    switch (status) {
      case 'مؤكد':
        return const [
          Color(0xFFE8F2EC),
          Color(0xFFD4E8DC),
        ];
      case 'ملغي':
      case 'ملغية':
        return const [
          Color(0xFFF8E9E8),
          Color(0xFFEFD5D3),
        ];
      case 'لم يحضر':
        return const [
          Color(0xFFFAF3EB),
          Color(0xFFF0E0D0),
        ];
      case 'مكتمل':
      case 'مكتملة':
        return const [
          Color(0xFFE8EEF6),
          Color(0xFFD6E2F0),
        ];
      default:
        return const [
          Color(0xFFF2EEF8),
          Color(0xFFE6DFF0),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: textColor.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  const _ActionsGrid({
    required this.onConfirm,
    required this.onCheckIn,
    required this.onNoShow,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCheckIn;
  final VoidCallback onNoShow;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AppointmentActionButton(
                label: 'تأكيد',
                icon: Icons.verified_rounded,
                color: const Color(0xFF3D7A5C),
                onTap: onConfirm,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AppointmentActionButton(
                label: 'تسجيل حضور',
                icon: Icons.done_all_rounded,
                color: const Color(0xFF4A6FA8),
                onTap: onCheckIn,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AppointmentActionButton(
                label: 'عدم حضور',
                icon: Icons.person_off_rounded,
                color: const Color(0xFFC2783A),
                onTap: onNoShow,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AppointmentActionButton(
                label: 'إلغاء',
                icon: Icons.close_rounded,
                color: const Color(0xFFC9544A),
                onTap: onCancel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AppointmentActionButton extends StatelessWidget {
  const _AppointmentActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF374151),
                size: 17,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualAppointmentTextField extends StatelessWidget {
  const _ManualAppointmentTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF5C4030),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FBFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFC47A3D),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ManualServiceDropdown extends StatelessWidget {
  const _ManualServiceDropdown({
    required this.selectedServiceName,
    required this.onChanged,
  });

  final String? selectedServiceName;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'نوع الخدمة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBFA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4ECE7),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedServiceName,
              isExpanded: true,
              hint: const Text('اختر الخدمة'),
              items: mockBarberServices.map((service) {
                return DropdownMenuItem<String>(
                  value: service.name,
                  child: Text(
                    '${service.name} - ${service.durationMinutes} دقيقة',
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        Material(
          color: const Color(0xFFF9FBFA),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4ECE7),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF5C4030),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ManualPrimaryButton extends StatelessWidget {
  const _ManualPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC47A3D),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}