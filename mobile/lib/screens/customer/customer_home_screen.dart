import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/barber_model.dart';
import '../../models/mock_appointment.dart';
import '../../models/mock_notification.dart';
import '../../widgets/customer/home/customer_home_top_bar.dart';
import '../../widgets/customer/home/customer_notifications_dropdown.dart';
import '../../widgets/customer/appointments/cancel_appointment_dialog.dart';
import '../../widgets/customer/appointments/rating_dialog.dart';
import '../../utils/appointment_filters.dart';
import '../../widgets/customer/home/customer_booking_cta_card.dart';
import '../../widgets/customer/home/customer_section_title_card.dart';
import '../../widgets/customer/home/customer_appointments_section.dart';
import 'customer_booking_screen.dart';
import 'customer_profile_screen.dart';
import 'customer_settings_screen.dart';
import '../../models/customer_profile_result.dart';


class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    super.key,
    required this.onLogout,
    required this.userName,
  });

  final VoidCallback onLogout;
  final String userName;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String displayName = 'يوسف';
  String countryCode = '+970';
  String phoneNumber = '599999999';
  bool isNotificationsDropdownOpen = false;
  String selectedAppointmentsTab = 'upcoming';
  late List<MockAppointment> appointments;

  @override
  void initState() {
    super.initState();

    final normalizedName = widget.userName.trim();
    if (normalizedName.isNotEmpty && normalizedName != 'customer') {
      displayName = normalizedName;
    }

    appointments = List<MockAppointment>.from(mockCustomerAppointments);
  }

  int get unreadNotifications =>
      mockCustomerNotifications.where((item) => !item.isRead).length;

  Future<void> _openProfile() async {
    final result = await Navigator.of(context).push<CustomerProfileResult>(
      MaterialPageRoute(
        builder: (_) => CustomerProfileScreen(
          initialDisplayName: displayName,
          initialCountryCode: countryCode,
          initialPhoneNumber: phoneNumber,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      displayName = result.displayName;
      countryCode = result.countryCode;
      phoneNumber = result.phoneNumber;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تحديث بياناتك بنجاح')));
  }

  void _openBooking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CustomerBookingScreen()),
    );
  }

  BarberModel? _findBarberForAppointment(MockAppointment appointment) {
    for (final barber in mockBarbers) {
      if (barber.name == appointment.barberName) {
        return barber;
      }
    }

    return null;
  }

  void _rebookAppointment(MockAppointment appointment) {
    final barber = _findBarberForAppointment(appointment);

    if (barber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر العثور على الحلاق لهذا الموعد')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerBookingScreen(preselectedBarber: barber),
      ),
    );
  }

  void _toggleNotificationsDropdown() {
    setState(() {
      isNotificationsDropdownOpen = !isNotificationsDropdownOpen;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CustomerSettingsScreen()),
    );
  }

  List<MockAppointment> get upcomingAppointments {
    return appointments.where(isUpcomingAppointment).toList();
  }

  List<MockAppointment> get previousAppointments {
    return appointments.where(isPreviousAppointment).toList();
  }

  Future<void> _cancelAppointment(MockAppointment appointment) async {
    final shouldCancel = await showCancelAppointmentDialog(
      context: context,
      barberName: appointment.barberName,
    );

    if (!mounted || shouldCancel != true) return;

    setState(() {
      appointments = appointments.map((item) {
        if (item.id != appointment.id) return item;

        return MockAppointment(
          id: item.id,
          customerName: item.customerName,
          barberName: item.barberName,
          barberRating: item.barberRating,
          serviceName: item.serviceName,
          dateLabel: item.dateLabel,
          timeLabel: item.timeLabel,
          status: 'ملغي',
          startDateTime: item.startDateTime,
          endDateTime: item.endDateTime,
        );
      }).toList();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم إلغاء الموعد مؤقتًا')));
  }

  Future<void> _openRatingDialog(MockAppointment appointment) async {
    final selectedStars = await showCustomerRatingDialog(
      context: context,
      barberName: appointment.barberName,
      barberRating: appointment.barberRating,
    );

    if (!mounted || selectedStars == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال تقييمك: $selectedStars نجوم (محلياً)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomerHomeTopBar(
                      displayName: displayName,
                      unreadCount: unreadNotifications,
                      onProfileTap: _openProfile,
                      onNotificationsTap: _toggleNotificationsDropdown,
                      onSettingsTap: _openSettings,
                      onLogoutTap: widget.onLogout,
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'أهلاً $displayName',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'جاهز لحجز موعدك اليوم؟',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 22),

                    CustomerBookingCtaCard(onStartBooking: _openBooking),

                    const SizedBox(height: 22),

                    const CustomerSectionTitleCard(title: 'مواعيدي'),

                    const SizedBox(height: 14),

                    CustomerAppointmentsSection(
                      selectedTab: selectedAppointmentsTab,
                      upcomingAppointments: upcomingAppointments,
                      previousAppointments: previousAppointments,
                      onTabChanged: (tab) {
                        setState(() {
                          selectedAppointmentsTab = tab;
                        });
                      },
                      onCancelAppointment: _cancelAppointment,
                      onRateAppointment: _openRatingDialog,
                      onRebookAppointment: _rebookAppointment,
                    ),
                  ],
                ),
              ),

              if (isNotificationsDropdownOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isNotificationsDropdownOpen = false;
                      });
                    },
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),
                ),

              if (isNotificationsDropdownOpen)
                Positioned(
                  top: 94,
                  left: 20,
                  right: 20,
                  child: CustomerNotificationsDropdown(
                    onClose: () {
                      setState(() {
                        isNotificationsDropdownOpen = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
