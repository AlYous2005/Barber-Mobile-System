class NotificationTableNames {
  const NotificationTableNames._();

  static const notifications = 'notifications';
}

class NotificationColumnNames {
  const NotificationColumnNames._();

  static const id = 'id';
  static const userId = 'user_id';
  static const type = 'type';
  static const title = 'title';
  static const message = 'message';
  static const isRead = 'is_read';
  static const relatedEntityType = 'related_entity_type';
  static const relatedEntityId = 'related_entity_id';
  static const createdAt = 'created_at';
}

class NotificationTypes {
  const NotificationTypes._();

  static const appointment = 'appointment';
  static const service = 'service';
  static const workingHours = 'working_hours';
  static const availability = 'availability';
  static const summary = 'summary';
  static const system = 'system';
}

class NotificationRelatedEntityTypes {
  const NotificationRelatedEntityTypes._();

  static const appointment = 'appointment';
  static const service = 'service';
  static const barber = 'barber';
  static const customer = 'customer';
}

/// Default batch size when loading notifications with pagination in the UI.
class NotificationPaging {
  const NotificationPaging._();

  static const int pageSize = 20;
}
