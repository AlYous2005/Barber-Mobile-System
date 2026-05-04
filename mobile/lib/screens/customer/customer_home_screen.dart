import 'package:flutter/material.dart';

import '../../models/mock_appointment.dart';
import '../../models/mock_notification.dart';
import '../../widgets/customer/customer_appointment_card.dart';
import '../../widgets/customer/customer_home_top_bar.dart';

import '../../models/barber_model.dart';
import 'customer_settings_screen.dart';
import 'customer_booking_screen.dart';
import 'customer_profile_screen.dart';
import 'dart:ui';

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

  bool _isPreviousAppointment(MockAppointment appointment) {
    final now = DateTime.now();

    return appointment.status == 'مكتمل' ||
        appointment.status == 'ملغي' ||
        appointment.endDateTime.isBefore(now);
  }

  List<MockAppointment> get upcomingAppointments {
    return appointments.where((appointment) {
      return !_isPreviousAppointment(appointment);
    }).toList();
  }

  List<MockAppointment> get previousAppointments {
    return appointments.where(_isPreviousAppointment).toList();
  }

  bool _canCancelAppointment(MockAppointment appointment) {
    return appointment.status == 'معلق' ||
        appointment.status == 'قادم' ||
        appointment.status == 'تم التأكيد';
  }

  void _cancelAppointment(MockAppointment appointment) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'إلغاء الموعد',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            content: Text(
              'هل أنت متأكد أنك تريد إلغاء موعدك عند الحلاق ${appointment.barberName}؟',
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'تراجع',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

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

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إلغاء الموعد مؤقتًا')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'إلغاء الموعد',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openRatingDialog(MockAppointment appointment) async {
    int selectedStars = 5;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'قيّم الحلاق',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            content: StatefulBuilder(
              builder: (context, setInnerState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الحلاق ${appointment.barberName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تقييمه الحالي ${appointment.barberRating.toStringAsFixed(1)} ★',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        return IconButton(
                          onPressed: () {
                            setInnerState(() {
                              selectedStars = value;
                            });
                          },
                          icon: Icon(
                            value <= selectedStars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 30,
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إرسال تقييمك: $selectedStars نجوم (محلياً)',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC47A3D),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'إرسال',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
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

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFF6E3F2F),
                            Color(0xFF9B5A3D),
                            Color(0xFFC47A3D),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x24000000),
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ابدأ حجزك الآن',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'اختر الحلاق، الخدمة، والوقت المناسب خلال ثوانٍ.',
                                          style: TextStyle(
                                            color: Color(0xFFF4E7D8),
                                            fontSize: 13.5,
                                            height: 1.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFFFFD08A),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'حجز سريع • مواعيد منظمة • بدون انتظار',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              SizedBox(
                                width: double.infinity,
                                child: Material(
                                  color: const Color(0xFFFFC46B),
                                  borderRadius: BorderRadius.circular(18),
                                  child: InkWell(
                                    onTap: _openBooking,
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x33FFC46B),
                                            blurRadius: 18,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ابدأ الحجز',
                                            style: TextStyle(
                                              color: Color(0xFF2A2018),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_back_rounded,
                                            color: Color(0xFF2A2018),
                                            size: 21,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEADBCD)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Text(
                        'مواعيدي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _AppointmentsTabsSelector(
                      selectedTab: selectedAppointmentsTab,
                      upcomingCount: upcomingAppointments.length,
                      previousCount: previousAppointments.length,
                      onTabChanged: (tab) {
                        setState(() {
                          selectedAppointmentsTab = tab;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    if (selectedAppointmentsTab == 'upcoming') ...[
                      if (upcomingAppointments.isEmpty)
                        const _EmptyAppointmentsBox(
                          message: 'لا توجد مواعيد قادمة حالياً',
                        )
                      else
                        ...upcomingAppointments.map(
                          (item) => CustomerAppointmentCard(
                            barberName: item.barberName,
                            barberRating: item.barberRating,
                            serviceName: item.serviceName,
                            dateLabel: item.dateLabel,
                            timeLabel: item.timeLabel,
                            status: item.status,
                            onRate: null,
                            onCancel: _canCancelAppointment(item)
                                ? () => _cancelAppointment(item)
                                : null,
                            onRebook: null,
                          ),
                        ),
                    ] else ...[
                      if (previousAppointments.isEmpty)
                        const _EmptyAppointmentsBox(
                          message: 'لا توجد مواعيد سابقة حالياً',
                        )
                      else
                        ...previousAppointments.map(
                          (item) => CustomerAppointmentCard(
                            barberName: item.barberName,
                            barberRating: item.barberRating,
                            serviceName: item.serviceName,
                            dateLabel: item.dateLabel,
                            timeLabel: item.timeLabel,
                            status: item.status,
                            onRate: item.isCompleted
                                ? () => _openRatingDialog(item)
                                : null,
                            onCancel: null,
                            onRebook: () => _rebookAppointment(item),
                          ),
                        ),
                    ],
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
                  child: _CustomerNotificationsDropdown(
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

class _CustomerNotificationsDropdown extends StatelessWidget {
  const _CustomerNotificationsDropdown({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final notifications = mockCustomerNotifications;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEADBCD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFC47A3D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'إشعاراتي',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (notifications.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'لا توجد إشعارات حالياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            ...notifications
                .take(4)
                .map(
                  (item) => _CustomerNotificationMiniCard(
                    message: item.message,
                    isRead: item.isRead,
                  ),
                ),
        ],
      ),
    );
  }
}

class _CustomerNotificationMiniCard extends StatelessWidget {
  const _CustomerNotificationMiniCard({
    required this.message,
    required this.isRead,
  });

  final String message;
  final bool isRead;

  String get readableMessage {
    if (message.contains('حجز')) {
      return 'تم تحديث حالة أحد حجوزاتك. يمكنك مراجعة تفاصيل الموعد من قسم مواعيدي.';
    }

    if (message.contains('تقييم')) {
      return 'يمكنك الآن تقييم الحلاق بعد اكتمال موعدك.';
    }

    if (message.contains('تأكيد')) {
      return 'تم تأكيد موعدك من قبل الحلاق.';
    }

    if (message.contains('إلغاء') || message.contains('ملغي')) {
      return 'تم إلغاء أحد مواعيدك. راجع قسم مواعيدي لمعرفة التفاصيل.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead ? const Color(0xFFE5E7EB) : const Color(0xFFF3D4A7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF3F4F6) : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
              color: isRead ? const Color(0xFF6B7280) : const Color(0xFFC47A3D),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              readableMessage,
              style: TextStyle(
                color: const Color(0xFF111827),
                fontSize: 13,
                height: 1.45,
                fontWeight: isRead ? FontWeight.w600 : FontWeight.w900,
              ),
            ),
          ),
          if (!isRead)
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }
}


class _EmptyAppointmentsBox extends StatelessWidget {
  const _EmptyAppointmentsBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AppointmentsTabsSelector extends StatelessWidget {
  const _AppointmentsTabsSelector({
    required this.selectedTab,
    required this.upcomingCount,
    required this.previousCount,
    required this.onTabChanged,
  });

  final String selectedTab;
  final int upcomingCount;
  final int previousCount;
  final ValueChanged<String> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEADBCD)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AppointmentTabButton(
              title: 'القادمة',
              count: upcomingCount,
              icon: Icons.event_available_rounded,
              isSelected: selectedTab == 'upcoming',
              onTap: () => onTabChanged('upcoming'),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _AppointmentTabButton(
              title: 'السابقة',
              count: previousCount,
              icon: Icons.history_rounded,
              isSelected: selectedTab == 'previous',
              onTap: () => onTabChanged('previous'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTabButton extends StatelessWidget {
  const _AppointmentTabButton({
    required this.title,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFC47A3D);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x22C47A3D),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : activeColor,
                size: 20,
              ),

              const SizedBox(width: 7),

              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B4F3E),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : activeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : activeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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
