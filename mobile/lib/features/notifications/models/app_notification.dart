import '../constants/notification_constants.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final String? relatedEntityType;
  final String? relatedEntityId;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map[NotificationColumnNames.id]?.toString() ?? '',
      title: map[NotificationColumnNames.title]?.toString() ?? '',
      message: map[NotificationColumnNames.message]?.toString() ?? '',
      type:
          map[NotificationColumnNames.type]?.toString() ??
          NotificationTypes.system,
      isRead: map[NotificationColumnNames.isRead] == true,
      createdAt: DateTime.tryParse(
        map[NotificationColumnNames.createdAt]?.toString() ?? '',
      ),
      relatedEntityType: map[NotificationColumnNames.relatedEntityType]
          ?.toString(),
      relatedEntityId: map[NotificationColumnNames.relatedEntityId]?.toString(),
    );
  }
}
