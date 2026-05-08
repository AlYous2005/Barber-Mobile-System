// notifications state + filters + database read logic

import 'package:flutter/material.dart';

import '../../models/barber_notification_ui_model.dart';
import '../../repositories/notification_repository.dart';
import '../../services/auth_session.dart';

class BarberNotificationsController extends ChangeNotifier {
  BarberNotificationsController({
    NotificationRepository notificationRepository =
        const NotificationRepository(),
  }) : _notificationRepository = notificationRepository;

  final NotificationRepository _notificationRepository;

  List<UiNotification> notifications = [];
  String selectedFilter = 'all';

  bool isLoading = false;
  String? errorMessage;

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

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_currentUserId.isEmpty) {
        throw Exception('Missing current user id');
      }

      final loadedNotifications = await _notificationRepository
          .getNotifications(userId: _currentUserId);

      notifications = loadedNotifications
          .map(UiNotification.fromAppNotification)
          .toList();
    } catch (error, stackTrace) {
      debugPrint('BarberNotificationsController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر تحميل الإشعارات، حاول مرة أخرى';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeFilter(String value) {
    selectedFilter = value;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final notification = notifications
        .where((item) => item.id == id)
        .firstOrNull;

    if (notification == null || notification.isRead) {
      return;
    }

    await _notificationRepository.markAsRead(notificationId: id);

    notifications = notifications.map((item) {
      if (item.id != id) return item;
      return item.copyWith(isRead: true);
    }).toList();

    notifyListeners();
  }

  Future<bool> markAllAsRead() async {
    final bool hadUnread = notifications.any((item) => !item.isRead);

    if (!hadUnread || _currentUserId.isEmpty) {
      return false;
    }

    await _notificationRepository.markAllAsRead(userId: _currentUserId);

    notifications = notifications
        .map((item) => item.copyWith(isRead: true))
        .toList();

    notifyListeners();
    return true;
  }
}
