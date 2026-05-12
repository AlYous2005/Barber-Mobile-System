import 'package:flutter/material.dart';

import '../constants/notification_constants.dart';
import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';
import '../../../services/auth_session.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends State<CustomerNotificationsScreen> {
  final NotificationRepository _notificationRepository =
      const NotificationRepository();

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreNotifications = true;
  String? errorMessage;
  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  bool _scrollNearBottom(ScrollMetrics metrics) {
    if (!metrics.hasPixels || !metrics.hasViewportDimension) {
      return false;
    }
    const double threshold = 220;
    return metrics.pixels >= metrics.maxScrollExtent - threshold;
  }

  Future<void> _loadNotifications() async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'لا يوجد مستخدم مسجل حاليًا';
      });
      return;
    }

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      hasMoreNotifications = true;
      errorMessage = null;
    });

    try {
      final List<AppNotification> loaded =
          await _notificationRepository.getNotifications(
            userId: currentUser.username,
            limit: NotificationPaging.pageSize,
            offset: 0,
          );

      notifications = loaded;
      hasMoreNotifications = loaded.length == NotificationPaging.pageSize;
    } catch (error) {
      errorMessage = 'تعذر تحميل الإشعارات، حاول مرة أخرى';
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (!hasMoreNotifications || isLoadingMore || isLoading) {
      return;
    }

    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final int offset = notifications.length;
      final List<AppNotification> batch =
          await _notificationRepository.getNotifications(
            userId: currentUser.username,
            limit: NotificationPaging.pageSize,
            offset: offset,
          );

      final Set<String> seen =
          notifications.map((AppNotification e) => e.id).toSet();
      final List<AppNotification> merged = [...notifications];
      for (final AppNotification row in batch) {
        if (seen.contains(row.id)) continue;
        seen.add(row.id);
        merged.add(row);
      }

      notifications = merged;
      hasMoreNotifications =
          batch.length == NotificationPaging.pageSize;
    } catch (_) {
      // Preserve existing list.
    } finally {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) {
      return;
    }

    await _notificationRepository.markAsRead(notificationId: notification.id);

    setState(() {
      notifications = notifications.map((item) {
        if (item.id != notification.id) return item;
        return item.copyWith(isRead: true);
      }).toList();
    });
  }

  Future<void> _markAllAsRead() async {
    final currentUser = AuthSession.currentUser;

    if (currentUser == null) {
      return;
    }

    await _notificationRepository.markAllAsRead(userId: currentUser.username);

    setState(() {
      notifications = notifications
          .map((item) => item.copyWith(isRead: true))
          .toList();
    });
  }

  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('إشعاراتي'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            TextButton(
              onPressed: unreadCount == 0 ? null : _markAllAsRead,
              child: const Text('تعيين الكل كمقروء'),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _loadNotifications,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            : notifications.isEmpty
            ? const Center(
                child: Text(
                  'لا توجد إشعارات حاليًا',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is! ScrollUpdateNotification &&
                      notification is! OverscrollNotification) {
                    return false;
                  }
                  if (_scrollNearBottom(notification.metrics)) {
                    _loadMoreNotifications();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length +
                      (isLoadingMore && hasMoreNotifications ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= notifications.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      );
                    }

                    final item = notifications[index];

                    return InkWell(
                      onTap: () => _markAsRead(item),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? const Color(0xFFF9FAFB)
                              : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.isRead
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.message,
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 13.5,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
