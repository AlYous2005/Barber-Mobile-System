import 'package:flutter/material.dart';

import '../../utils/app_theme_colors.dart';
import '../../models/mock_notification.dart';
import 'barber_appointments_screen.dart';
import 'barber_availability_screen.dart';
import 'barber_services_screen.dart';
import 'barber_summary_screen.dart';
import 'barber_working_hours_screen.dart';
import '../../models/barber_notification_ui_model.dart';
import '../../widgets/barber/notifications/notifications_actions_bar.dart';
import '../../widgets/barber/notifications/notifications_filter_bar.dart';
import '../../widgets/barber/notifications/empty_notifications_state.dart';
import '../../widgets/barber/notifications/notification_luxury_card.dart';
import '../../widgets/barber/notifications/notifications_intro_card.dart';

class BarberNotificationsScreen extends StatefulWidget {
  const BarberNotificationsScreen({super.key});

  @override
  State<BarberNotificationsScreen> createState() =>
      _BarberNotificationsScreenState();
}

class _BarberNotificationsScreenState extends State<BarberNotificationsScreen> {
  late List<UiNotification> notifications;

  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    notifications = mockBarberNotifications.asMap().entries.map((entry) {
      final int index = entry.key;
      final item = entry.value;

      return UiNotification(
        id: 'notification-$index',
        message: item.message,
        isRead: item.isRead,
        type: _detectNotificationType(item.message),
        timeLabel: _mockTimeLabel(index),
      );
    }).toList();

    if (notifications.isEmpty) {
      notifications = const [
        UiNotification(
          id: 'n1',
          message: 'لديك حجز جديد من أحمد خالد لخدمة حلاقة شعر + لحية',
          isRead: false,
          type: NotificationType.appointment,
          timeLabel: 'قبل 5 دقائق',
        ),
        UiNotification(
          id: 'n2',
          message: 'تم اكتمال موعد محمد علي بنجاح',
          isRead: true,
          type: NotificationType.summary,
          timeLabel: 'قبل ساعة',
        ),
        UiNotification(
          id: 'n3',
          message: 'تم تحديث ساعات العمل لهذا الأسبوع',
          isRead: false,
          type: NotificationType.workingHours,
          timeLabel: 'اليوم',
        ),
        UiNotification(
          id: 'n4',
          message: 'تمت إضافة فترة عدم توفر جديدة',
          isRead: true,
          type: NotificationType.availability,
          timeLabel: 'أمس',
        ),
      ];
    }
  }

  static NotificationType _detectNotificationType(String message) {
    if (message.contains('حجز') ||
        message.contains('موعد') ||
        message.contains('زبون')) {
      return NotificationType.appointment;
    }

    if (message.contains('خدمة') || message.contains('الخدمات')) {
      return NotificationType.service;
    }

    if (message.contains('ساعات') || message.contains('العمل')) {
      return NotificationType.workingHours;
    }

    if (message.contains('إغلاق') ||
        message.contains('التوفر') ||
        message.contains('عدم توفر')) {
      return NotificationType.availability;
    }

    if (message.contains('مكتمل') ||
        message.contains('إيرادات') ||
        message.contains('ملخص')) {
      return NotificationType.summary;
    }

    return NotificationType.system;
  }

  static String _mockTimeLabel(int index) {
    switch (index) {
      case 0:
        return 'الآن';
      case 1:
        return 'قبل 10 دقائق';
      case 2:
        return 'قبل ساعة';
      case 3:
        return 'اليوم';
      default:
        return 'حديثًا';
    }
  }

  List<UiNotification> get filteredNotifications {
    switch (selectedFilter) {
      case 'unread':
        return notifications.where((item) => !item.isRead).toList();
      case 'appointments':
        return notifications
            .where((item) => item.type == NotificationType.appointment)
            .toList();
      case 'system':
        return notifications
            .where(
              (item) =>
                  item.type == NotificationType.system ||
                  item.type == NotificationType.workingHours ||
                  item.type == NotificationType.availability ||
                  item.type == NotificationType.service,
            )
            .toList();
      default:
        return notifications;
    }
  }

  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  void _markAsRead(String id) {
    setState(() {
      notifications = notifications.map((item) {
        if (item.id != id) return item;
        return item.copyWith(isRead: true);
      }).toList();
    });
  }

  void _openNotification(UiNotification notification) {
    _markAsRead(notification.id);

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

  void _markAllAsRead() {
    setState(() {
      notifications = notifications.map((item) {
        return item.copyWith(isRead: true);
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعليم كل الإشعارات كمقروءة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<UiNotification> visibleNotifications = filteredNotifications;

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
            NotificationsIntroCard(unreadCount: unreadCount),

            const SizedBox(height: 14),

            NotificationsActionsBar(
              unreadCount: unreadCount,
              onMarkAllAsRead: _markAllAsRead,
            ),

            const SizedBox(height: 14),

            NotificationsFilterBar(
              selectedFilter: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
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
  }
}
