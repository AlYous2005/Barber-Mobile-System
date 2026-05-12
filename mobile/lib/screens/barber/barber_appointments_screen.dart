// UI + dialogs + popups

import 'package:flutter/material.dart';

import '../../features/bookings/bookings.dart';
import '../../controllers/barber/barber_appointments_controller.dart';
import '../../widgets/barber/appointments/add_manual_appointment_button.dart';
import '../../widgets/barber/appointments/add_manual_appointment_sheet.dart';
import '../../widgets/barber/appointments/appointment_action_widgets.dart';
import '../../widgets/barber/appointments/appointments_intro_card.dart';
import '../../widgets/barber/appointments/appointments_list_section.dart';
import '../../widgets/barber/appointments/appointments_subnav.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

class BarberAppointmentsScreen extends StatefulWidget {
  const BarberAppointmentsScreen({super.key});

  @override
  State<BarberAppointmentsScreen> createState() =>
      _BarberAppointmentsScreenState();
}

class _BarberAppointmentsScreenState extends State<BarberAppointmentsScreen> {
  late final BarberAppointmentsController controller;

  static const double _appointmentsScrollLoadThresholdPx = 140;

  bool _appointmentsScrollNearBottom(ScrollMetrics metrics) {
    if (!metrics.hasPixels || !metrics.hasViewportDimension) {
      return false;
    }
    return metrics.pixels >=
        metrics.maxScrollExtent - _appointmentsScrollLoadThresholdPx;
  }

  @override
  void initState() {
    super.initState();

    controller = BarberAppointmentsController();
    controller.loadBarberAppointments();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _showSuccessPopup({
    required String title,
    required String message,
    required IconData icon,
    Color iconStartColor = const Color(0xFF16A34A),
    Color iconEndColor = const Color(0xFF86EFAC),
  }) async {
    if (!mounted) return;

    await showBarberFeedbackPopup(
      context: context,
      title: title,
      message: message,
      icon: icon,
      iconStartColor: iconStartColor,
      iconEndColor: iconEndColor,
    );
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

            await _showSuccessPopup(
              title: 'تمت إضافة الموعد',
              message: 'تمت إضافة الموعد الجديد بنجاح',
              icon: Icons.check_circle_rounded,
            );
          },
          onAddAppointment: controller.addManualAppointment,
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

                        try {
                          await controller.updateStatus(
                            appointment.id,
                            newStatus,
                          );
                        } catch (error) {
                          if (!mounted) return;

                          if (error
                              is BarberAppointmentsSyncConflictException) {
                            await _showSuccessPopup(
                              title: 'تم تحديث الموعد',
                              message:
                                  'تعذر تحديث حالة الموعد , بسبب تغيير حالته من قبل الطرف الاخر. سيتم تحديث القوائم الان',
                              icon: Icons.sync_problem_rounded,
                              iconStartColor: const Color(0xFF2563EB),
                              iconEndColor: const Color(0xFF93C5FD),
                            );
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تعذر تحديث حالة الموعد، حاول مرة أخرى',
                                ),
                              ),
                            );
                          }
                          return;
                        }

                        if (!mounted) return;

                        await _showSuccessPopup(
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
      message:
          'هل تريد تأكيد موعد الزبون "${appointment.displayCustomerName}"؟',
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
          'هل تريد تسجيل حضور "${appointment.displayCustomerName}" وإنهاء الموعد؟',
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
      message:
          'هل تريد تسجيل أن الزبون "${appointment.displayCustomerName}" لم يحضر؟',
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
      message:
          'هل تريد إلغاء موعد الزبون "${appointment.displayCustomerName}"؟',
      confirmText: 'إلغاء الموعد',
      color: const Color(0xFFC9544A),
      successTitle: 'تم إلغاء الموعد',
      successMessage: 'تم إلغاء موعد الزبون بنجاح',
      successIcon: Icons.event_busy_rounded,
      successStartColor: const Color(0xFFDC2626),
      successEndColor: const Color(0xFFFCA5A5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
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
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is! ScrollUpdateNotification &&
                    notification is! OverscrollNotification) {
                  return false;
                }
                if (!controller.hasMoreAppointments ||
                    controller.isLoadingMoreAppointments ||
                    controller.isLoadingAppointments) {
                  return false;
                }
                if (_appointmentsScrollNearBottom(notification.metrics)) {
                  controller.loadMoreAppointments();
                }
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  const AppointmentsSectionIntro(),

                  const SizedBox(height: 14),

                  AddManualAppointmentButton(
                    onTap: _openAddManualAppointmentSheet,
                  ),

                  const SizedBox(height: 14),

                  AppointmentsSubnav(
                    selectedTab: controller.selectedTab,
                    onChanged: controller.changeTab,
                  ),

                  const SizedBox(height: 16),

                  if (controller.isLoadingAppointments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.appointmentsErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 42),
                          const SizedBox(height: 12),
                          Text(
                            controller.appointmentsErrorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: controller.loadBarberAppointments,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    AppointmentsListSection(
                      title: controller.activeListTitle,
                      emptyText: controller.activeEmptyText,
                      appointments: controller.activeAppointments,
                      isFinalStatus: controller.isFinalStatus,
                      onConfirm: _handleConfirmAppointment,
                      onCheckIn: _handleCheckIn,
                      onNoShow: _handleNoShow,
                      onCancel: _handleCancel,
                    ),
                    if (controller.isLoadingMoreAppointments)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
