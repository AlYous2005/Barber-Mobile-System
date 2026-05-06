// UI + navigation + dialogs/popups
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../controllers/customer/customer_home_controller.dart';
import '../../models/customer_profile_result.dart';
import '../../models/mock_appointment.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/customer/appointments/cancel_appointment_dialog.dart';
import '../../widgets/customer/appointments/rating_dialog.dart';
import '../../widgets/customer/home/customer_appointments_section.dart';
import '../../widgets/customer/home/customer_booking_cta_card.dart';
import '../../widgets/customer/home/customer_home_top_bar.dart';
import '../../widgets/customer/home/customer_notifications_dropdown.dart';
import '../../widgets/customer/home/customer_section_title_card.dart';
import '../../widgets/customer/shared/customer_feedback_popup.dart';
import 'customer_booking_screen.dart';
import 'customer_profile_screen.dart';

import 'customer_settings_screen.dart';

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
  late final CustomerHomeController controller;

  late final AnimationController _greetingAnimController;
  late final Animation<double> _greetingFade;
  late final Animation<Offset> _greetingSlide;
  late final Animation<double> _greetingScale;

  @override
  void initState() {
    super.initState();

    controller = CustomerHomeController(initialUserName: widget.userName);
    controller.loadCustomerAppointments();

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
    controller.dispose();
    super.dispose();
  }

  Future<void> _openProfile() async {
    final result = await Navigator.of(context).push<CustomerProfileResult>(
      MaterialPageRoute(
        builder: (_) => CustomerProfileScreen(
          initialDisplayName: controller.displayName,
          initialCountryCode: controller.countryCode,
          initialPhoneNumber: controller.phoneNumber,
        ),
      ),
    );

    if (!mounted || result == null) return;

    controller.updateProfile(result);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تحديث بياناتك بنجاح')));
  }

  Future<void> _openBooking() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CustomerBookingScreen()),
    );

    if (!mounted) return;

    await controller.loadCustomerAppointments();
  }

  Future<void> _rebookAppointment(MockAppointment appointment) async {
    final barber = await controller.resolveBarberForRebook(appointment);

    if (!mounted) return;

    if (barber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر العثور على الحلاق لهذا الموعد')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerBookingScreen(preselectedBarber: barber),
      ),
    );

    if (!mounted) return;

    await controller.loadCustomerAppointments();
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CustomerSettingsScreen()),
    );
  }

  Future<void> _cancelAppointment(MockAppointment appointment) async {
    final shouldCancel = await showCancelAppointmentDialog(
      context: context,
      barberName: appointment.barberName,
    );

    if (!mounted || shouldCancel != true) return;

    controller.cancelAppointmentLocally(appointment);

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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
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
                          displayName: controller.displayName,
                          unreadCount: controller.unreadNotifications,
                          onProfileTap: _openProfile,
                          onNotificationsTap:
                              controller.toggleNotificationsDropdown,
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
                                      'أهلًا ${controller.greetingFirstName}',
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
                                            ? AppThemeColors.textSecondary(
                                                context,
                                              )
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

                        if (controller.isLoadingAppointments)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (controller.appointmentsErrorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 42,
                                ),
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
                                  onPressed:
                                      controller.loadCustomerAppointments,
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          )
                        else
                          CustomerAppointmentsSection(
                            selectedTab: controller.selectedAppointmentsTab,
                            upcomingAppointments:
                                controller.upcomingAppointments,
                            previousAppointments:
                                controller.previousAppointments,
                            onTabChanged: controller.changeAppointmentsTab,
                            onCancelAppointment: _cancelAppointment,
                            onRateAppointment: _openRatingDialog,
                            onRebookAppointment: (appointment) {
                              _rebookAppointment(appointment);
                            },
                          ),
                      ],
                    ),
                  ),

                  if (controller.isNotificationsDropdownOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: controller.closeNotificationsDropdown,
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

                  if (controller.isNotificationsDropdownOpen)
                    Positioned(
                      top: 94,
                      left: 20,
                      right: 20,
                      child: CustomerNotificationsDropdown(
                        notifications: controller.customerNotifications,
                        onMarkAllAsRead: controller.markAllNotificationsAsRead,
                        onClose: controller.closeNotificationsDropdown,
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
}
