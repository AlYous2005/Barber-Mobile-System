class NotificationPayload {
  const NotificationPayload({
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  final String userId;
  final String type;
  final String title;
  final String message;
  final String? relatedEntityType;
  final String? relatedEntityId;
}
