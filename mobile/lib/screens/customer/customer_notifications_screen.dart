import 'package:flutter/material.dart';

import '../../models/mock_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../services/auth_session.dart';

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
  String? errorMessage;
  List<MockNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
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
      errorMessage = null;
    });

    try {
      notifications = await _notificationRepository.getNotifications(
        userId: currentUser.username,
      );
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

  Future<void> _markAsRead(MockNotification notification) async {
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
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
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
    );
  }
}
