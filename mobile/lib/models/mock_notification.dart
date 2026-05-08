class MockNotification {
  const MockNotification({
    required this.id,
    required this.message,
    this.title = 'إشعار',
    this.type = 'system',
    this.isRead = false,
    this.createdAt,
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

  MockNotification copyWith({bool? isRead}) {
    return MockNotification(
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

  factory MockNotification.fromMap(Map<String, dynamic> map) {
    return MockNotification(
      id: map['id'].toString(),
      title: (map['title'] ?? 'إشعار').toString(),
      message: (map['message'] ?? '').toString(),
      type: (map['type'] ?? 'system').toString(),
      isRead: map['is_read'] == true,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
      relatedEntityType: map['related_entity_type']?.toString(),
      relatedEntityId: map['related_entity_id']?.toString(),
    );
  }
}
