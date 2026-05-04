import 'package:flutter/material.dart';

import '../../models/mock_notification.dart';
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
  late List<_UiNotification> notifications;

  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    notifications = mockBarberNotifications.asMap().entries.map((entry) {
      final int index = entry.key;
      final item = entry.value;

      return _UiNotification(
        id: 'notification-$index',
        message: item.message,
        isRead: item.isRead,
        type: _detectNotificationType(item.message),
        timeLabel: _mockTimeLabel(index),
      );
    }).toList();

    if (notifications.isEmpty) {
      notifications = const [
        _UiNotification(
          id: 'n1',
          message: 'لديك حجز جديد من أحمد خالد لخدمة حلاقة شعر + لحية',
          isRead: false,
          type: _NotificationType.appointment,
          timeLabel: 'قبل 5 دقائق',
        ),
        _UiNotification(
          id: 'n2',
          message: 'تم اكتمال موعد محمد علي بنجاح',
          isRead: true,
          type: _NotificationType.summary,
          timeLabel: 'قبل ساعة',
        ),
        _UiNotification(
          id: 'n3',
          message: 'تم تحديث ساعات العمل لهذا الأسبوع',
          isRead: false,
          type: _NotificationType.workingHours,
          timeLabel: 'اليوم',
        ),
        _UiNotification(
          id: 'n4',
          message: 'تمت إضافة فترة عدم توفر جديدة',
          isRead: true,
          type: _NotificationType.availability,
          timeLabel: 'أمس',
        ),
      ];
    }
  }

  static _NotificationType _detectNotificationType(String message) {
    if (message.contains('حجز') ||
        message.contains('موعد') ||
        message.contains('زبون')) {
      return _NotificationType.appointment;
    }

    if (message.contains('خدمة') || message.contains('الخدمات')) {
      return _NotificationType.service;
    }

    if (message.contains('ساعات') || message.contains('العمل')) {
      return _NotificationType.workingHours;
    }

    if (message.contains('إغلاق') ||
        message.contains('التوفر') ||
        message.contains('عدم توفر')) {
      return _NotificationType.availability;
    }

    if (message.contains('مكتمل') ||
        message.contains('إيرادات') ||
        message.contains('ملخص')) {
      return _NotificationType.summary;
    }

    return _NotificationType.system;
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

  List<_UiNotification> get filteredNotifications {
    switch (selectedFilter) {
      case 'unread':
        return notifications.where((item) => !item.isRead).toList();
      case 'appointments':
        return notifications
            .where((item) => item.type == _NotificationType.appointment)
            .toList();
      case 'system':
        return notifications
            .where(
              (item) =>
                  item.type == _NotificationType.system ||
                  item.type == _NotificationType.workingHours ||
                  item.type == _NotificationType.availability ||
                  item.type == _NotificationType.service,
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

  void _openNotification(_UiNotification notification) {
    _markAsRead(notification.id);

    switch (notification.type) {
      case _NotificationType.appointment:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberAppointmentsScreen(),
          ),
        );
        break;

      case _NotificationType.service:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberServicesScreen(),
          ),
        );
        break;

      case _NotificationType.workingHours:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberWorkingHoursScreen(),
          ),
        );
        break;

      case _NotificationType.availability:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberAvailabilityScreen(),
          ),
        );
        break;

      case _NotificationType.summary:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BarberSummaryScreen(),
          ),
        );
        break;

      case _NotificationType.system:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذا إشعار نظامي فقط'),
          ),
        );
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
      const SnackBar(
        content: Text('تم تعليم كل الإشعارات كمقروءة'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_UiNotification> visibleNotifications = filteredNotifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _NotificationsIntroCard(
              unreadCount: unreadCount,
            ),

            const SizedBox(height: 14),

            _NotificationsActionsBar(
              unreadCount: unreadCount,
              onMarkAllAsRead: _markAllAsRead,
            ),

            const SizedBox(height: 14),

            _NotificationsFilterBar(
              selectedFilter: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),

            const SizedBox(height: 16),

            if (visibleNotifications.isEmpty)
              const _EmptyNotificationsState()
            else
              ...visibleNotifications.map(
                (notification) => _NotificationLuxuryCard(
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

class _NotificationsIntroCard extends StatelessWidget {
  const _NotificationsIntroCard({
    required this.unreadCount,
  });

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6E3F2F),
            Color(0xFF9B5A3D),
            Color(0xFFC37A49),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _NotificationsCenterPill(),

          const SizedBox(height: 14),

          const Text(
            'الإشعارات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'تابع الحجوزات والتحديثات المهمة لحظة بلحظة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: Text(
              unreadCount == 0
                  ? 'كل الإشعارات مقروءة'
                  : '$unreadCount إشعارات غير مقروءة',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsCenterPill extends StatelessWidget {
  const _NotificationsCenterPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.notifications_active_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsActionsBar extends StatelessWidget {
  const _NotificationsActionsBar({
    required this.unreadCount,
    required this.onMarkAllAsRead,
  });

  final int unreadCount;
  final VoidCallback onMarkAllAsRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEADBCD),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: Color(0xFFC47A3D),
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              unreadCount == 0
                  ? 'لا يوجد إشعارات تحتاج متابعة'
                  : 'عندك $unreadCount إشعارات غير مقروءة',
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A2018),
              ),
            ),
          ),

          const SizedBox(width: 10),

          if (unreadCount > 0)
            Material(
              color: const Color(0xFFC47A3D),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onMarkAllAsRead,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: const Text(
                    'قراءة الكل',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationsFilterBar extends StatelessWidget {
  const _NotificationsFilterBar({
    required this.selectedFilter,
    required this.onChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8D8B8),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FilterChipButton(
            label: 'الكل',
            value: 'all',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChipButton(
            label: 'غير مقروء',
            value: 'unread',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChipButton(
            label: 'الحجوزات',
            value: 'appointments',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
          _FilterChipButton(
            label: 'النظام',
            value: 'system',
            selectedFilter: selectedFilter,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.value,
    required this.selectedFilter,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedFilter;

    return Material(
      color: isSelected ? const Color(0xFF9A5A38) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF9A5A38)
                  : const Color(0xFFE3D3C6),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : const Color(0xFF6B4F3E),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationLuxuryCard extends StatelessWidget {
  const _NotificationLuxuryCard({
    required this.notification,
    required this.onTap,
  });

  final _UiNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _NotificationVisual visual = _visualFor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: notification.isRead
            ? const Color(0xFFFFFFFF)
            : visual.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: notification.isRead
                    ? const Color(0xFFE5E7EB)
                    : visual.color.withValues(alpha: 0.24),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: visual.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: visual.color.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Icon(
                        visual.icon,
                        color: visual.color,
                        size: 23,
                      ),
                    ),

                    if (!notification.isRead)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEF4444),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _NotificationBadge(
                            label: visual.label,
                            color: visual.color,
                          ),

                          const Spacer(),

                          Text(
                            notification.timeLabel,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: notification.isRead
                              ? FontWeight.w700
                              : FontWeight.w900,
                          color: const Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 11),

                      Row(
                        children: [
                          Text(
                            visual.actionText,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: visual.color,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: visual.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static _NotificationVisual _visualFor(_NotificationType type) {
    switch (type) {
      case _NotificationType.appointment:
        return const _NotificationVisual(
          label: 'حجز',
          actionText: 'فتح المواعيد',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFF2563EB),
        );

      case _NotificationType.service:
        return const _NotificationVisual(
          label: 'خدمة',
          actionText: 'فتح الخدمات',
          icon: Icons.content_cut_rounded,
          color: Color(0xFFC47A3D),
        );

      case _NotificationType.workingHours:
        return const _NotificationVisual(
          label: 'ساعات العمل',
          actionText: 'فتح ساعات العمل',
          icon: Icons.schedule_rounded,
          color: Color(0xFF16A34A),
        );

      case _NotificationType.availability:
        return const _NotificationVisual(
          label: 'توفر',
          actionText: 'فتح التوفر والإغلاقات',
          icon: Icons.event_busy_rounded,
          color: Color(0xFF8B5CF6),
        );

      case _NotificationType.summary:
        return const _NotificationVisual(
          label: 'إنجاز',
          actionText: 'فتح الملخصات',
          icon: Icons.bar_chart_rounded,
          color: Color(0xFFF59E0B),
        );

      case _NotificationType.system:
        return const _NotificationVisual(
          label: 'نظام',
          actionText: 'عرض التفاصيل',
          icon: Icons.info_rounded,
          color: Color(0xFF64748B),
        );
    }
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF9CA3AF),
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'لا توجد إشعارات في هذا القسم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationType {
  appointment,
  service,
  workingHours,
  availability,
  summary,
  system,
}

class _UiNotification {
  const _UiNotification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.type,
    required this.timeLabel,
  });

  final String id;
  final String message;
  final bool isRead;
  final _NotificationType type;
  final String timeLabel;

  _UiNotification copyWith({
    bool? isRead,
  }) {
    return _UiNotification(
      id: id,
      message: message,
      isRead: isRead ?? this.isRead,
      type: type,
      timeLabel: timeLabel,
    );
  }
}

class _NotificationVisual {
  const _NotificationVisual({
    required this.label,
    required this.actionText,
    required this.icon,
    required this.color,
  });

  final String label;
  final String actionText;
  final IconData icon;
  final Color color;
}