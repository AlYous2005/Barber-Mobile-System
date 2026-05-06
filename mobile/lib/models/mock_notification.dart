class MockNotification {
  const MockNotification({
    required this.id,
    required this.message,
    this.isRead = false,
  });

  final String id;
  final String message;
  final bool isRead;
}


