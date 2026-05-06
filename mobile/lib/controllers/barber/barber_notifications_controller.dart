//  notifications state + filters + type detection + read logic


import 'package:flutter/material.dart';

import '../../data/mocks/mock_notifications.dart';
import '../../models/barber_notification_ui_model.dart';

class BarberNotificationsController extends ChangeNotifier {
  BarberNotificationsController() {
    _loadMockNotifications();
  }

  List<UiNotification> notifications = [];
  String selectedFilter = 'all';

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

  void changeFilter(String value) {
    selectedFilter = value;
    notifyListeners();
  }

  void markAsRead(String id) {
    notifications = notifications.map((item) {
      if (item.id != id) return item;
      return item.copyWith(isRead: true);
    }).toList();

    notifyListeners();
  }

  bool markAllAsRead() {
    final bool hadUnread = notifications.any((item) => !item.isRead);

    if (!hadUnread) {
      return false;
    }

    notifications = notifications
        .map((item) => item.copyWith(isRead: true))
        .toList();

    notifyListeners();
    return true;
  }

  void _loadMockNotifications() {
    notifications = mockBarberNotifications.asMap().entries.map((entry) {
      final int index = entry.key;
      final item = entry.value;

      return UiNotification(
        id: 'notification-$index',
        message: item.message,
        isRead: item.isRead,
        type: detectNotificationType(item.message),
        timeLabel: mockTimeLabel(index),
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

  static NotificationType detectNotificationType(String message) {
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

  static String mockTimeLabel(int index) {
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
}