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
import '../../widgets/customer/shared/customer_feedback_popup.dart';
import 'customer_booking_screen.dart';
import 'customer_profile_screen.dart';
import 'customer_settings_screen.dart';
import '../../models/customer_profile_result.dart';
import '../../utils/app_theme_colors.dart';

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

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  String displayName = 'يوسف';
  String countryCode = '+970';
  String phoneNumber = '599999999';
  bool isNotificationsDropdownOpen = false;
  String selectedAppointmentsTab = 'upcoming';
  late List<MockAppointment> appointments;
  late List<MockNotification> customerNotifications;

  late final AnimationController _greetingAnimController;
  late final Animation<double> _greetingFade;
  late final Animation<Offset> _greetingSlide;
  late final Animation<double> _greetingScale;

  @override
  void initState() {
    super.initState();

    final normalizedName = widget.userName.trim();
    if (normalizedName.isNotEmpty && normalizedName != 'customer') {
      displayName = normalizedName;
    }

    appointments = List<MockAppointment>.from(mockCustomerAppointments);
    customerNotifications = List<MockNotification>.from(
      mockCustomerNotifications,
    );

    _greetingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    final CurvedAnimation curved = CurvedAnimation(
      parent: _greetingAnimController,
      curve: Curves.easeOutCubic,
    );

    _greetingFade = Tween<double>(begin: 0, end: 1).animate(curved);
    _greetingSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);
    _greetingScale = Tween<double>(begin: 0.96, end: 1).animate(curved);

    _greetingAnimController.forward();
  }

  @override
  void dispose() {
    _greetingAnimController.dispose();
    super.dispose();
  }

  int get unreadNotifications =>
      customerNotifications.where((item) => !item.isRead).length;

  /// First token of [displayName] for the home greeting (full name stays in header/profile).
  String get _greetingFirstName {
    final String trimmed = displayName.trim();
    if (trimmed.isEmpty) return trimmed;
    final List<String> parts = trimmed.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : trimmed;
  }

  void _markAllNotificationsAsRead() {
    if (unreadNotifications == 0) return;

    setState(() {
      customerNotifications = customerNotifications
          .map(
            (item) => item.isRead
                ? item
                : MockNotification(
                    id: item.id,
                    message: item.message,
                    isRead: true,
                  ),
          )
          .toList();
    });
  }

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

    await showCustomerFeedbackPopup(
      context: context,
      title: 'تم إلغاء موعدك',
      message:
          'يجب التواصل مع الحلاق لإعادة الموعد، أو قم بحجزه مرة أخرى بنفسك إذا ما زال متوفرًا.',
      icon: Icons.event_busy_rounded,
      iconStartColor: const Color(0xFFEF4444),
      iconEndColor: const Color(0xFFFCA5A5),
    );
  }

  Future<void> _openRatingDialog(MockAppointment appointment) async {
    final selectedStars = await showCustomerRatingDialog(
      context: context,
      barberName: appointment.barberName,
      barberRating: appointment.barberRating,
    );

    if (!mounted || selectedStars == null) return;

    if (selectedStars > 4) {
      await showCustomerFeedbackPopup(
        context: context,
        title: 'تم إرسال التقييم',
        message: 'شكلو الحلاق مزبطك 😉',
        icon: Icons.celebration_rounded,
      );
      return;
    }

    if (selectedStars < 4) {
      await showCustomerFeedbackPopup(
        context: context,
        title: 'تم إرسال تقييمك',
        message: 'نتمنى لك تجربة أجمل',
        icon: Icons.favorite_rounded,
        iconStartColor: const Color(0xFFEF4444),
        iconEndColor: const Color(0xFFFCA5A5),
      );
      return;
    }

    await showCustomerFeedbackPopup(
      context: context,
      title: 'تم إرسال تقييمك',
      message: 'شكرًا لمشاركتك رأيك معنا',
      icon: Icons.star_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBackground = Theme.of(context).scaffoldBackgroundColor;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBackground,
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

                    FadeTransition(
                      opacity: _greetingFade,
                      child: SlideTransition(
                        position: _greetingSlide,
                        child: ScaleTransition(
                          scale: _greetingScale,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'أهلًا $_greetingFirstName',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppThemeColors.isDark(context)
                                        ? const Color(0xFFF6D38B)
                                        : const Color(0xFF111827),
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  'جاهز لحجز موعدك القادم؟',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppThemeColors.isDark(context)
                                        ? AppThemeColors.textSecondary(context)
                                        : const Color(0xFF4B5563),
                                    fontSize: 16,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                    notifications: customerNotifications,
                    onMarkAllAsRead: _markAllNotificationsAsRead,
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
