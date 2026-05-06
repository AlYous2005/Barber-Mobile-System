// UI + navigation + popups

import 'package:flutter/material.dart';

import '../../controllers/barber/barber_notifications_controller.dart';
import '../../models/barber_notification_ui_model.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/barber/notifications/empty_notifications_state.dart';
import '../../widgets/barber/notifications/notification_luxury_card.dart';
import '../../widgets/barber/notifications/notifications_actions_bar.dart';
import '../../widgets/barber/notifications/notifications_filter_bar.dart';
import '../../widgets/barber/notifications/notifications_intro_card.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';
import 'barber_appointments_screen.dart';
import 'barber_availability_screen.dart';
import 'barber_services_screen.dart';
import 'barber_summary_screen.dart';
import 'barber_working_hours_screen.dart';

class BarberNotificationsScreen extends StatefulWidget {
  const BarberNotificationsScreen({super.key});

  @override
  State<BarberNotificationsScreen> createState() =>
      _BarberNotificationsScreenState();
}

class _BarberNotificationsScreenState extends State<BarberNotificationsScreen> {
  late final BarberNotificationsController controller;

  static const Color _successGreenStart = Color(0xFF16A34A);
  static const Color _successGreenEnd = Color(0xFF86EFAC);
  static const Color _mutedIconStart = Color(0xFF9A8B7E);
  static const Color _mutedIconEnd = Color(0xFFC4B8AD);

  @override
  void initState() {
    super.initState();
    controller = BarberNotificationsController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openNotification(UiNotification notification) {
    controller.markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.appointment:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberAppointmentsScreen(),
          ),
        );
        break;

      case NotificationType.service:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BarberServicesScreen()),
        );
        break;

      case NotificationType.workingHours:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberWorkingHoursScreen(),
          ),
        );
        break;

      case NotificationType.availability:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberAvailabilityScreen(),
          ),
        );
        break;

      case NotificationType.summary:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BarberSummaryScreen()),
        );
        break;

      case NotificationType.system:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('هذا إشعار نظامي فقط')));
        break;
    }
  }

  Future<void> _markAllAsRead() async {
    final bool hadUnread = controller.markAllAsRead();

    if (!mounted) return;

    if (!hadUnread) {
      await showBarberFeedbackPopup(
        context: context,
        title: 'لا توجد إشعارات جديدة',
        message: 'جميع الإشعارات مقروءة بالفعل',
        icon: Icons.notifications_none_rounded,
        iconStartColor: _mutedIconStart,
        iconEndColor: _mutedIconEnd,
      );
      return;
    }

    await showBarberFeedbackPopup(
      context: context,
      title: 'تم تعيين الإشعارات كمقروءة',
      message: 'تم تعيين جميع الإشعارات كمقروءة بنجاح',
      icon: Icons.done_all_rounded,
      iconStartColor: _successGreenStart,
      iconEndColor: _successGreenEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final List<UiNotification> visibleNotifications =
            controller.filteredNotifications;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                NotificationsIntroCard(unreadCount: controller.unreadCount),

                const SizedBox(height: 14),

                NotificationsActionsBar(
                  unreadCount: controller.unreadCount,
                  onMarkAllAsRead: _markAllAsRead,
                ),

                const SizedBox(height: 14),

                NotificationsFilterBar(
                  selectedFilter: controller.selectedFilter,
                  onChanged: controller.changeFilter,
                ),

                const SizedBox(height: 16),

                if (visibleNotifications.isEmpty)
                  const EmptyNotificationsState()
                else
                  ...visibleNotifications.map(
                    (notification) => NotificationLuxuryCard(
                      notification: notification,
                      onTap: () => _openNotification(notification),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}