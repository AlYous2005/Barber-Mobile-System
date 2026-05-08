import 'package:flutter/material.dart';

import 'mock_notification.dart';

enum NotificationType {
  appointment,
  service,
  workingHours,
  availability,
  summary,
  system,
}

class UiNotification {
  const UiNotification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.type,
    required this.timeLabel,
    this.title,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  final String id;
  final String? title;
  final String message;
  final bool isRead;
  final NotificationType type;
  final String timeLabel;
  final String? relatedEntityType;
  final String? relatedEntityId;

  UiNotification copyWith({bool? isRead}) {
    return UiNotification(
      id: id,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      type: type,
      timeLabel: timeLabel,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
    );
  }

  factory UiNotification.fromAppNotification(MockNotification notification) {
    return UiNotification(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      isRead: notification.isRead,
      type: notificationTypeFromDatabase(notification.type),
      timeLabel: timeLabelFromDate(notification.createdAt),
      relatedEntityType: notification.relatedEntityType,
      relatedEntityId: notification.relatedEntityId,
    );
  }
}

NotificationType notificationTypeFromDatabase(String value) {
  switch (value) {
    case 'appointment':
      return NotificationType.appointment;
    case 'service':
      return NotificationType.service;
    case 'working_hours':
      return NotificationType.workingHours;
    case 'availability':
      return NotificationType.availability;
    case 'summary':
      return NotificationType.summary;
    case 'system':
    default:
      return NotificationType.system;
  }
}

String timeLabelFromDate(DateTime? date) {
  if (date == null) {
    return 'حديثًا';
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) {
    return 'الآن';
  }

  if (difference.inMinutes < 60) {
    return 'قبل ${difference.inMinutes} دقائق';
  }

  if (difference.inHours < 24) {
    return 'قبل ${difference.inHours} ساعة';
  }

  if (difference.inDays == 1) {
    return 'أمس';
  }

  if (difference.inDays < 7) {
    return 'قبل ${difference.inDays} أيام';
  }

  return '${date.day}/${date.month}/${date.year}';
}

class NotificationVisual {
  const NotificationVisual({
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
