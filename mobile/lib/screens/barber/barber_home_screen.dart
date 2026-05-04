import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../models/mock_notification.dart';
import '../../widgets/barber/menu/barber_dropdown_menu.dart';
import '../../widgets/barber/header/barber_header.dart';
import '../../widgets/barber/profile/barber_profile_sheet.dart';
import '../../widgets/barber/timeline/barber_timeline_card.dart';
import 'barber_availability_screen.dart';
import 'barber_working_hours_screen.dart';
import 'barber_appointments_screen.dart';
import 'barber_notifications_screen.dart';
import 'barber_services_screen.dart';
import 'barber_settings_screen.dart';
import 'barber_summary_screen.dart';
import '../../widgets/barber/home/barber_profile_preview.dart';
import '../../widgets/barber/home/home_appointment_card.dart';
import '../../widgets/barber/home/home_appointments_header.dart';
import '../../widgets/barber/home/home_stats_section.dart';

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
  bool showCurrent = true;
  bool isMenuOpen = false;
  String barberDisplayName = 'يوسف';
  String selectedAppointmentFilter = 'معلقة';

  int get unreadNotifications {
    return mockBarberNotifications.where((item) => !item.isRead).length;
  }

  MockAppointment? get currentTimelineAppointment {
    for (final appointment in mockBarberAppointments) {
      if (appointment.isCurrent) {
        return appointment;
      }
    }

    return null;
  }

  MockAppointment? get upcomingTimelineAppointment {
    for (final appointment in mockBarberAppointments) {
      if (appointment.isUpcoming) {
        return appointment;
      }
    }

    return null;
  }

  List<MockAppointment> get filteredAppointments {
    if (selectedAppointmentFilter == 'الكل') {
      return mockBarberAppointments;
    }

    return mockBarberAppointments.where((appointment) {
      return appointment.status == selectedAppointmentFilter;
    }).toList();
  }

  String get appointmentsSectionTitle {
    switch (selectedAppointmentFilter) {
      case 'معلقة':
        return 'المواعيد المعلقة لليوم';
      case 'مؤكدة':
        return 'المواعيد المؤكدة لليوم';
      case 'مكتملة':
        return 'المواعيد المكتملة لليوم';
      case 'ملغية':
        return 'المواعيد الملغية لليوم';
      default:
        return 'كل مواعيد اليوم';
    }
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

  void _openAppointments() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BarberAppointmentsScreen()),
    );
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

  void _openMenu() {
    setState(() {
      isMenuOpen = true;
    });
  }

  void _closeMenu() {
    setState(() {
      isMenuOpen = false;
    });
  }

  void _openBarberProfile() {
    showBarberProfileSheet(
      context: context,
      barberName: barberDisplayName,
      onNameSaved: (newName) {
        setState(() {
          barberDisplayName = newName;
        });
      },
    );
  }

  void _showTemporaryMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BarberHeader(
                      userName: barberDisplayName,
                      rating: 4.8,
                      unreadNotifications: unreadNotifications,
                      onNotificationsTap: _openNotifications,
                      onMenuTap: _openMenu,
                    ),

                    const SizedBox(height: 16),

                    BarberProfilePreview(onTap: _openBarberProfile),

                    const SizedBox(height: 18),

                    BarberTimelineCard(
                      currentAppointment: currentTimelineAppointment,
                      upcomingAppointment: upcomingTimelineAppointment,
                      showCurrent: showCurrent,
                      onToggle: () {
                        setState(() {
                          showCurrent = !showCurrent;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    HomeStatsSection(
                      selectedAppointmentFilter: selectedAppointmentFilter,
                      onFilterChanged: (value) {
                        setState(() {
                          selectedAppointmentFilter = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    HomeAppointmentsHeader(
                      title: appointmentsSectionTitle,
                      onShowAll: () {
                        setState(() {
                          selectedAppointmentFilter = 'الكل';
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    if (filteredAppointments.isEmpty)
                      HomeAppointmentsEmptyState(
                        selectedAppointmentFilter: selectedAppointmentFilter,
                      )
                    else
                      ...filteredAppointments.map(
                        (appointment) => HomeAppointmentCard(
                          appointment: appointment,
                          onMarkCompleted: () {
                            _showTemporaryMessage(
                              'سيتم لاحقًا تغيير حالة الموعد إلى مكتمل',
                            );
                          },
                          onCancel: () {
                            _showTemporaryMessage('سيتم لاحقًا إلغاء الموعد');
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            BarberDropdownMenu(
              isOpen: isMenuOpen,
              onClose: _closeMenu,
              onServicesTap: () {
                _closeMenu();
                _openServices();
              },
              onAppointmentsTap: () {
                _closeMenu();
                _openAppointments();
              },
              onAvailabilityTap: () {
                _closeMenu();
                _openAvailability();
              },
              onWorkingHoursTap: () {
                _closeMenu();
                _openWorkingHours();
              },
              onSummaryTap: () {
                _closeMenu();
                _openSummary();
              },
              onSettingsTap: () {
                _closeMenu();
                _openSettings();
              },
              onLogoutTap: () {
                _closeMenu();
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
