import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';

import '../../widgets/barber/appointments/add_manual_appointment_button.dart';
import '../../widgets/barber/appointments/appointments_intro_card.dart';
import '../../widgets/barber/appointments/appointments_subnav.dart';
import '../../widgets/barber/appointments/appointment_action_widgets.dart';
import '../../widgets/barber/appointments/appointments_list_section.dart';
import '../../widgets/barber/appointments/add_manual_appointment_sheet.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

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
          onAddedSuccessfully: () async {
            if (!mounted) return;
            await showBarberFeedbackPopup(
              context: this.context,
              title: 'تمت إضافة الموعد',
              message: 'تمت إضافة الموعد الجديد بنجاح',
              icon: Icons.check_circle_rounded,
            );
          },
          onAddAppointment: (appointment) {
            setState(() {
              appointments.insert(0, appointment);
            });
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
    required String successTitle,
    required String successMessage,
    required IconData successIcon,
    required Color successStartColor,
    required Color successEndColor,
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
                      onTap: () async {
                        Navigator.of(context).pop();
                        _updateStatus(appointment.id, newStatus);
                        if (!mounted) return;
                        await showBarberFeedbackPopup(
                          context: this.context,
                          title: successTitle,
                          message: successMessage,
                          icon: successIcon,
                          iconStartColor: successStartColor,
                          iconEndColor: successEndColor,
                        );
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
      successTitle: 'تم تأكيد الموعد',
      successMessage: 'تم تأكيد موعد الزبون بنجاح',
      successIcon: Icons.check_circle_rounded,
      successStartColor: const Color(0xFF16A34A),
      successEndColor: const Color(0xFF86EFAC),
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
      successTitle: 'تم تسجيل الحضور',
      successMessage: 'تم تسجيل حضور الزبون وإنهاء الموعد بنجاح',
      successIcon: Icons.person_pin_circle_rounded,
      successStartColor: const Color(0xFF2563EB),
      successEndColor: const Color(0xFF93C5FD),
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
      successTitle: 'تم تسجيل عدم الحضور',
      successMessage: 'تم تسجيل أن الزبون لم يحضر للموعد',
      successIcon: Icons.person_off_rounded,
      successStartColor: const Color(0xFFF59E0B),
      successEndColor: const Color(0xFFFCD34D),
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
      successTitle: 'تم إلغاء الموعد',
      successMessage: 'تم إلغاء موعد الزبون بنجاح',
      successIcon: Icons.event_busy_rounded,
      successStartColor: const Color(0xFFDC2626),
      successEndColor: const Color(0xFFFCA5A5),
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
    final Color pageBackground = Theme.of(context).scaffoldBackgroundColor;
    final Color appBarTextColor =
        Theme.of(context).appBarTheme.iconTheme?.color ??
        Theme.of(context).colorScheme.onSurface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: appBarTextColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: pageBackground,
          surfaceTintColor: pageBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: appBarTextColor),
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
