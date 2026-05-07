// UI + navigation + profile sheet + snackbars

import 'package:flutter/material.dart';

import '../../controllers/barber/barber_home_controller.dart';
import '../../widgets/barber/header/barber_header.dart';
import '../../widgets/barber/home/barber_profile_preview.dart';
import '../../widgets/barber/home/home_appointment_card.dart';
import '../../widgets/barber/home/home_appointments_header.dart';
import '../../widgets/barber/home/home_stats_section.dart';
import '../../widgets/barber/menu/barber_dropdown_menu.dart';
import '../../widgets/barber/profile/barber_profile_sheet.dart';
import '../../widgets/barber/timeline/barber_timeline_card.dart';
import 'barber_appointments_screen.dart';
import 'barber_availability_screen.dart';
import 'barber_notifications_screen.dart';
import 'barber_services_screen.dart';
import 'barber_settings_screen.dart';
import 'barber_summary_screen.dart';
import 'barber_working_hours_screen.dart';
import '../../models/mock_appointment.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

class BarberHomeScreen extends StatefulWidget {
  const BarberHomeScreen({
    super.key,
    required this.onLogout,
    required this.userName,
  });

  final VoidCallback onLogout;
  final String userName;

  @override
  State<BarberHomeScreen> createState() => _BarberHomeScreenState();
}

class _BarberHomeScreenState extends State<BarberHomeScreen> {
  late final BarberHomeController controller;

  @override
  void initState() {
    super.initState();

    controller = BarberHomeController();
    controller.loadBarberAppointments();
    controller.loadBarberAvatar();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BarberNotificationsScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BarberSettingsScreen(onLogout: widget.onLogout),
      ),
    );
  }

  void _openServices() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BarberServicesScreen()),
    );
  }

  Future<void> _openAppointments() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const BarberAppointmentsScreen()),
    );

    if (!mounted) return;

    await controller.loadBarberAppointments();
  }

  void _openSummary() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BarberSummaryScreen()),
    );
  }

  void _openAvailability() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BarberAvailabilityScreen()),
    );
  }

  void _openWorkingHours() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BarberWorkingHoursScreen()),
    );
  }

  Future<void> _openBarberProfile() async {
    await showBarberProfileSheet(
      context: context,
      barberName: controller.barberDisplayName,
      onNameSaved: controller.updateBarberDisplayName,
    );

    if (!mounted) return;

    await controller.loadBarberAvatar();
  }

  void _closeMenuThen(VoidCallback action) {
    controller.closeMenu();
    action();
  }

  Future<void> _closeMenuThenAsync(Future<void> Function() action) async {
    controller.closeMenu();
    await action();
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
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.7, fontWeight: FontWeight.w600),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('رجوع'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: color),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  try {
                    await controller.updateAppointmentStatus(
                      appointmentId: appointment.id,
                      status: newStatus,
                    );

                    if (!mounted) return;

                    await _showSuccessPopup(
                      title: successTitle,
                      message: successMessage,
                      icon: successIcon,
                      iconStartColor: successStartColor,
                      iconEndColor: successEndColor,
                    );
                  } catch (error) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تعذر تحديث حالة الموعد، حاول مرة أخرى'),
                      ),
                    );
                  }
                },
                child: Text(confirmText),
              ),
            ],
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

  void _handleCompleteAppointment(MockAppointment appointment) {
    _confirmStatusChange(
      appointment: appointment,
      newStatus: 'مكتمل',
      title: 'إنهاء الموعد',
      message:
          'هل تريد إنهاء موعد "${appointment.displayCustomerName}" كمكتمل؟',
      confirmText: 'مكتمل',
      color: const Color(0xFF4A6FA8),
      successTitle: 'تم إنهاء الموعد',
      successMessage: 'تم تغيير حالة الموعد إلى مكتمل',
      successIcon: Icons.done_all_rounded,
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

  void _handleCancelAppointment(MockAppointment appointment) {
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

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: pageBackground,
            body: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BarberHeader(
                          userName: controller.barberDisplayName,
                          rating: 4.8,
                          unreadNotifications: controller.unreadNotifications,
                          onNotificationsTap: _openNotifications,
                          onMenuTap: controller.openMenu,
                        ),

                        const SizedBox(height: 16),

                        BarberProfilePreview(
                          avatarUrl: controller.barberAvatarUrl,
                          onTap: _openBarberProfile,
                        ),

                        const SizedBox(height: 18),

                        BarberTimelineCard(
                          currentAppointment:
                              controller.currentTimelineAppointment,
                          upcomingAppointment:
                              controller.upcomingTimelineAppointment,
                          showCurrent: controller.showCurrent,
                          onToggle: controller.toggleTimelineMode,
                        ),

                        const SizedBox(height: 16),

                        HomeStatsSection(
                          selectedAppointmentFilter:
                              controller.selectedAppointmentFilter,
                          pendingAppointmentsCount:
                              controller.pendingAppointmentsCount,
                          confirmedAppointmentsCount:
                              controller.confirmedAppointmentsCount,
                          completedAppointmentsCount:
                              controller.completedAppointmentsCount,
                          cancelledAppointmentsCount:
                              controller.cancelledAppointmentsCount,
                          onFilterChanged: controller.changeAppointmentFilter,
                        ),

                        const SizedBox(height: 16),

                        HomeAppointmentsHeader(
                          title: controller.appointmentsSectionTitle,
                          onShowAll: controller.showAllAppointments,
                        ),

                        const SizedBox(height: 10),

                        if (controller.isLoadingAppointments)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (controller.appointmentsErrorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              controller.appointmentsErrorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else if (controller.filteredAppointments.isEmpty)
                          HomeAppointmentsEmptyState(
                            selectedAppointmentFilter:
                                controller.selectedAppointmentFilter,
                          )
                        else
                          ...controller.filteredAppointments.map(
                            (appointment) => HomeAppointmentCard(
                              appointment: appointment,
                              onConfirm: () =>
                                  _handleConfirmAppointment(appointment),
                              onMarkCompleted: () =>
                                  _handleCompleteAppointment(appointment),
                              onNoShow: () => _handleNoShow(appointment),
                              onCancel: () =>
                                  _handleCancelAppointment(appointment),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                BarberDropdownMenu(
                  isOpen: controller.isMenuOpen,
                  onClose: controller.closeMenu,
                  onServicesTap: () {
                    _closeMenuThen(_openServices);
                  },
                  onAppointmentsTap: () {
                    _closeMenuThenAsync(_openAppointments);
                  },
                  onAvailabilityTap: () {
                    _closeMenuThen(_openAvailability);
                  },
                  onWorkingHoursTap: () {
                    _closeMenuThen(_openWorkingHours);
                  },
                  onSummaryTap: () {
                    _closeMenuThen(_openSummary);
                  },
                  onSettingsTap: () {
                    _closeMenuThen(_openSettings);
                  },
                  onLogoutTap: () {
                    controller.closeMenu();
                    widget.onLogout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
