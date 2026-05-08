import '../models/mock_notification.dart';
import '../services/supabase_config.dart';

class NotificationRepository {
  const NotificationRepository();

  Future<List<MockNotification>> getNotifications({
    required String userId,
    int limit = 30,
  }) async {
    final rows = await SupabaseConfig.client
        .from('notifications')
        .select(
          'id, type, title, message, is_read, related_entity_type, related_entity_id, created_at',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map<MockNotification>((row) {
      return MockNotification.fromMap(row);
    }).toList();
  }

  Future<int> getUnreadCount({required String userId}) async {
    final rows = await SupabaseConfig.client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return rows.length;
  }

  Future<void> markAsRead({required String notificationId}) async {
    await SupabaseConfig.client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead({required String userId}) async {
    await SupabaseConfig.client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    await SupabaseConfig.client.from('notifications').insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': false,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
    });
  }
}
