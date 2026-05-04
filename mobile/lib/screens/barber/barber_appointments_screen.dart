import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';

import '../../widgets/barber/appointments/add_manual_appointment_button.dart';
import '../../widgets/barber/appointments/appointments_intro_card.dart';
import '../../widgets/barber/appointments/appointments_subnav.dart';
import '../../widgets/barber/appointments/appointment_action_widgets.dart';
import '../../widgets/barber/appointments/appointments_list_section.dart';
import '../../widgets/barber/appointments/add_manual_appointment_sheet.dart';

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
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddManualAppointmentSheet(
          onMessage: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          onAddAppointment: (appointment) {
            setState(() {
              appointments.insert(0, appointment);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت إضافة الموعد اليدوي بنجاح')),
            );
          },
        );
      },
    );
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
                    child: AppointmentActionButton(
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
                    child: SecondaryButton(
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
      message:
          'هل تريد تسجيل حضور "${appointment.customerName}" وإنهاء الموعد؟',
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
            const AppointmentsSectionIntro(),

            const SizedBox(height: 14),

            AddManualAppointmentButton(onTap: _openAddManualAppointmentSheet),

            const SizedBox(height: 14),

            AppointmentsSubnav(
              selectedTab: selectedTab,
              onChanged: (value) {
                setState(() {
                  selectedTab = value;
                });
              },
            ),

            const SizedBox(height: 16),

            AppointmentsListSection(
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
