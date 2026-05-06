import 'package:flutter/material.dart';

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
  });

  final String id;
  final String message;
  final bool isRead;
  final NotificationType type;
  final String timeLabel;

  UiNotification copyWith({bool? isRead}) {
    return UiNotification(
      id: id,
      message: message,
      isRead: isRead ?? this.isRead,
      type: type,
      timeLabel: timeLabel,
    );
  }
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
