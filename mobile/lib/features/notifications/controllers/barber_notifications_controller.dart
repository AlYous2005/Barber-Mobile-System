// notifications state + filters + database read logic

import 'package:flutter/material.dart';

import '../constants/notification_constants.dart';
import '../models/barber_notification_ui_model.dart';
import '../repositories/notification_repository.dart';
import '../../../services/auth_session.dart';

class BarberNotificationsController extends ChangeNotifier {
  BarberNotificationsController({
    NotificationRepository notificationRepository =
        const NotificationRepository(),
  }) : _notificationRepository = notificationRepository;

  final NotificationRepository _notificationRepository;

  List<UiNotification> notifications = [];
  String selectedFilter = 'all';

  final Set<String> _visitedFilterBadges = <String>{};

  bool isLoading = false;
  bool isLoadingMoreNotifications = false;
  bool hasMoreNotifications = true;
  String? errorMessage;

  List<UiNotification> get filteredNotifications {
    switch (selectedFilter) {
      case 'unread':
        return notifications.where((item) => !item.isRead).toList();

      case 'appointments':
        return notifications
            .where((item) => item.type == NotificationType.appointment)
            .toList();

      case 'customer_access_requests':
        return notifications
            .where(
              (item) => item.type == NotificationType.customerAccessRequest,
            )
            .toList();

      case 'system':
        return notifications.where((item) {
          return item.type == NotificationType.system ||
              item.type == NotificationType.workingHours ||
              item.type == NotificationType.availability ||
              item.type == NotificationType.service ||
              item.type == NotificationType.summary;
        }).toList();

      default:
        return notifications;
    }
  }

  int _badgeCountForFilter(String filter, int rawCount) {
    if (_visitedFilterBadges.contains(filter)) {
      return 0;
    }

    return rawCount;
  }

  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  int get appointmentsCount {
    return notifications
        .where((item) => item.type == NotificationType.appointment)
        .length;
  }

  int get unreadBadgeCount {
    return _badgeCountForFilter('unread', unreadCount);
  }

  int get appointmentsBadgeCount {
    return _badgeCountForFilter('appointments', appointmentsCount);
  }

  int get customerAccessRequestsBadgeCount {
    return _badgeCountForFilter(
      'customer_access_requests',
      customerAccessRequestsCount,
    );
  }

  int get systemBadgeCount {
    return _badgeCountForFilter('system', systemCount);
  }

  int get customerAccessRequestsCount {
    return notifications
        .where((item) => item.type == NotificationType.customerAccessRequest)
        .length;
  }

  int get systemCount {
    return notifications.where((item) {
      return item.type == NotificationType.system ||
          item.type == NotificationType.workingHours ||
          item.type == NotificationType.availability ||
          item.type == NotificationType.service ||
          item.type == NotificationType.summary;
    }).length;
  }

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    isLoadingMoreNotifications = false;
    hasMoreNotifications = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_currentUserId.isEmpty) {
        throw Exception('Missing current user id');
      }

      final loadedNotifications = await _notificationRepository
          .getNotifications(
            userId: _currentUserId,
            limit: NotificationPaging.pageSize,
            offset: 0,
          );

      notifications = loadedNotifications
          .map(UiNotification.fromAppNotification)
          .toList();
      hasMoreNotifications =
          loadedNotifications.length == NotificationPaging.pageSize;
    } catch (error, stackTrace) {
      debugPrint('BarberNotificationsController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'تعذر تحميل الإشعارات، حاول مرة أخرى';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoading || isLoadingMoreNotifications || !hasMoreNotifications) {
      return;
    }

    if (_currentUserId.isEmpty) {
      return;
    }

    isLoadingMoreNotifications = true;
    notifyListeners();

    try {
      final int offset = notifications.length;
      final loaded = await _notificationRepository.getNotifications(
        userId: _currentUserId,
        limit: NotificationPaging.pageSize,
        offset: offset,
      );

      final existingIds = notifications.map((n) => n.id).toSet();
      final mapped = loaded.map(UiNotification.fromAppNotification).where((n) {
        if (existingIds.contains(n.id)) {
          return false;
        }
        existingIds.add(n.id);
        return true;
      }).toList();

      notifications = [...notifications, ...mapped];
      hasMoreNotifications = loaded.length == NotificationPaging.pageSize;
    } catch (error, stackTrace) {
      debugPrint('BarberNotificationsController load more error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoadingMoreNotifications = false;
      notifyListeners();
    }
  }

  void changeFilter(String value) {
    selectedFilter = value;

    if (value != 'all') {
      _visitedFilterBadges.add(value);
    }

    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final notification = notifications
        .where((item) => item.id == id)
        .firstOrNull;

    if (notification == null || notification.isRead) {
      return;
    }

    // Optimistic local update so unread badge changes immediately on tap.
    notifications = notifications.map((item) {
      if (item.id != id) return item;
      return item.copyWith(isRead: true);
    }).toList();

    notifyListeners();

    try {
      await _notificationRepository.markAsRead(notificationId: id);
    } catch (error, stackTrace) {
      debugPrint('BarberNotificationsController markAsRead error: $error');
      debugPrintStack(stackTrace: stackTrace);
      await loadNotifications();
    }
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
