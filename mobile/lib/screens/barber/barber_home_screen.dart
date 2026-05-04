import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../models/mock_notification.dart';
import '../../widgets/barber/barber_dropdown_menu.dart';
import '../../widgets/barber/barber_header.dart';
import '../../widgets/barber/barber_profile_sheet.dart';
import '../../widgets/barber/barber_timeline_card.dart';
import 'barber_availability_screen.dart';
import 'barber_working_hours_screen.dart';
import '../../widgets/shared/star_rating_display.dart';
import '../../widgets/shared/stat_card.dart';
import 'barber_appointments_screen.dart';
import 'barber_notifications_screen.dart';
import 'barber_services_screen.dart';
import 'barber_settings_screen.dart';
import 'barber_summary_screen.dart';

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

                    _BarberProfilePreview(onTap: _openBarberProfile),

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

                    Center(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 28),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text(
                          'إحصائيات اليوم',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;

                        final int columns = width < 520 ? 2 : 4;
                        final double aspectRatio = width < 380 ? 1.25 : 1.45;

                        return GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: aspectRatio,
                              ),
                          children: [
                            StatCard(
                              title: 'مواعيد معلقة',
                              value: '3',
                              color: const Color(0xFFF59E0B),
                              isSelected: selectedAppointmentFilter == 'معلقة',
                              onTap: () {
                                setState(() {
                                  selectedAppointmentFilter = 'معلقة';
                                });
                              },
                            ),
                            StatCard(
                              title: 'مواعيد مؤكدة',
                              value: '9',
                              color: const Color(0xFF60A5FA),
                              isSelected: selectedAppointmentFilter == 'مؤكدة',
                              onTap: () {
                                setState(() {
                                  selectedAppointmentFilter = 'مؤكدة';
                                });
                              },
                            ),
                            StatCard(
                              title: 'مواعيد مكتملة',
                              value: '7',
                              color: const Color(0xFF34D399),
                              isSelected: selectedAppointmentFilter == 'مكتملة',
                              onTap: () {
                                setState(() {
                                  selectedAppointmentFilter = 'مكتملة';
                                });
                              },
                            ),
                            StatCard(
                              title: 'مواعيد ملغية',
                              value: '2',
                              color: const Color(0xFFF87171),
                              isSelected: selectedAppointmentFilter == 'ملغية',
                              onTap: () {
                                setState(() {
                                  selectedAppointmentFilter = 'ملغية';
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointmentsSectionTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAppointmentFilter = 'الكل';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x330EA5E9),
                                    blurRadius: 12,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'كل مواعيد اليوم',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (filteredAppointments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          selectedAppointmentFilter == 'الكل'
                              ? 'لا توجد مواعيد اليوم'
                              : 'لا توجد مواعيد ضمن هذا القسم',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      )
                    else
                      ...filteredAppointments.map(
                        (appointment) => _HomeAppointmentLuxuryCard(
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

class _BarberProfilePreview extends StatelessWidget {
  const _BarberProfilePreview({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Ink(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFC47A3D), Color(0xFFF6D38B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC47A3D).withValues(alpha: 0.26),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(
                        radius: 43,
                        backgroundColor: Color(0xFFF8FAFC),
                        child: Icon(
                          Icons.content_cut_rounded,
                          size: 38,
                          color: Color(0xFFC47A3D),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 5,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22C55E),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF22C55E,
                                ).withValues(alpha: 0.65),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          const StarRatingDisplay(
            rating: 4.8,
            ratingCount: 27,
            satisfactionRate: 96,
            starSize: 18,
            enableDetailsPopup: true,
          ),
        ],
      ),
    );
  }
}

class _HomeAppointmentLuxuryCard extends StatelessWidget {
  const _HomeAppointmentLuxuryCard({
    required this.appointment,
    required this.onMarkCompleted,
    required this.onCancel,
  });

  final MockAppointment appointment;
  final VoidCallback onMarkCompleted;
  final VoidCallback onCancel;

  bool get _isFinal {
    return appointment.status == 'مكتمل' ||
        appointment.status == 'مكتملة' ||
        appointment.status == 'ملغي' ||
        appointment.status == 'ملغية' ||
        appointment.status == 'لم يحضر';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1A4A3428)),
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
          _HomeAppointmentStatusBadge(status: appointment.status),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAECE0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x33C8A078)),
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

          _HomeAppointmentDetailLine(
            icon: Icons.content_cut_rounded,
            text: appointment.serviceName,
          ),

          const SizedBox(height: 10),

          _HomeAppointmentDetailLine(
            icon: Icons.access_time_rounded,
            text: appointment.timeLabel,
          ),

          const SizedBox(height: 10),

          _HomeAppointmentDetailLine(
            icon: Icons.calendar_month_rounded,
            text: appointment.dateLabel,
          ),

          if (!_isFinal) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _HomeAppointmentActionButton(
                    label: 'مكتمل',
                    icon: Icons.done_all_rounded,
                    color: const Color(0xFF4A6FA8),
                    onTap: onMarkCompleted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HomeAppointmentActionButton(
                    label: 'إلغاء',
                    icon: Icons.close_rounded,
                    color: const Color(0xFFC9544A),
                    onTap: onCancel,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeAppointmentDetailLine extends StatelessWidget {
  const _HomeAppointmentDetailLine({required this.icon, required this.text});

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
            border: Border.all(color: const Color(0x38C8AA8C)),
          ),
          child: Icon(icon, color: const Color(0xFF6B4F3E), size: 17),
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

class _HomeAppointmentStatusBadge extends StatelessWidget {
  const _HomeAppointmentStatusBadge({required this.status});

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
        return const [Color(0xFFE8F2EC), Color(0xFFD4E8DC)];
      case 'ملغي':
      case 'ملغية':
        return const [Color(0xFFF8E9E8), Color(0xFFEFD5D3)];
      case 'لم يحضر':
        return const [Color(0xFFFAF3EB), Color(0xFFF0E0D0)];
      case 'مكتمل':
      case 'مكتملة':
        return const [Color(0xFFE8EEF6), Color(0xFFD6E2F0)];
      default:
        return const [Color(0xFFF2EEF8), Color(0xFFE6DFF0)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: textColor.withValues(alpha: 0.22)),
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

class _HomeAppointmentActionButton extends StatelessWidget {
  const _HomeAppointmentActionButton({
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
              Icon(icon, color: Colors.white, size: 17),
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
