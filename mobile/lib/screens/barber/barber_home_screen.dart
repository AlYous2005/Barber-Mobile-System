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

  void _openBarberProfile() {
    showBarberProfileSheet(
      context: context,
      barberName: controller.barberDisplayName,
      onNameSaved: controller.updateBarberDisplayName,
    );
  }

  void _showTemporaryMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _closeMenuThen(VoidCallback action) {
    controller.closeMenu();
    action();
  }

  Future<void> _closeMenuThenAsync(Future<void> Function() action) async {
    controller.closeMenu();
    await action();
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

                        BarberProfilePreview(onTap: _openBarberProfile),

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
                              onMarkCompleted: () {
                                _showTemporaryMessage(
                                  'سيتم لاحقًا تغيير حالة الموعد إلى مكتمل',
                                );
                              },
                              onCancel: () {
                                _showTemporaryMessage(
                                  'سيتم لاحقًا إلغاء الموعد',
                                );
                              },
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
