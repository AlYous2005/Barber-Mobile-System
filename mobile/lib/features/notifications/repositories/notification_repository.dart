import '../../../services/supabase_config.dart';
import '../constants/notification_constants.dart';
import '../models/app_notification.dart';
import '../models/notification_payload.dart';

class NotificationRepository {
  const NotificationRepository();

  Future<List<AppNotification>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    if (limit <= 0) {
      return [];
    }

    final int from = offset;
    final int to = offset + limit - 1;

    final rows = await SupabaseConfig.client
        .from(NotificationTableNames.notifications)
        .select()
        .eq(NotificationColumnNames.userId, userId)
        .order(NotificationColumnNames.createdAt, ascending: false)
        .range(from, to);

    return rows
        .map<AppNotification>((row) => AppNotification.fromMap(row))
        .toList();
  }

  Future<int> getUnreadCount({required String userId}) async {
    final rows = await SupabaseConfig.client
        .from(NotificationTableNames.notifications)
        .select(NotificationColumnNames.id)
        .eq(NotificationColumnNames.userId, userId)
        .eq(NotificationColumnNames.isRead, false);

    return rows.length;
  }

  Future<void> markAsRead({required String notificationId}) async {
    await SupabaseConfig.client
        .from(NotificationTableNames.notifications)
        .update({NotificationColumnNames.isRead: true})
        .eq(NotificationColumnNames.id, notificationId);
  }

  Future<void> markAllAsRead({required String userId}) async {
    await SupabaseConfig.client
        .from(NotificationTableNames.notifications)
        .update({NotificationColumnNames.isRead: true})
        .eq(NotificationColumnNames.userId, userId)
        .eq(NotificationColumnNames.isRead, false);
  }

  Future<void> createFromPayload(NotificationPayload payload) {
    return createNotification(
      userId: payload.userId,
      type: payload.type,
      title: payload.title,
      message: payload.message,
      relatedEntityType: payload.relatedEntityType,
      relatedEntityId: payload.relatedEntityId,
    );
  }

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    await SupabaseConfig.client
        .from(NotificationTableNames.notifications)
        .insert({
          NotificationColumnNames.userId: userId,
          NotificationColumnNames.type: type,
          NotificationColumnNames.title: title,
          NotificationColumnNames.message: message,
          NotificationColumnNames.relatedEntityType: relatedEntityType,
          NotificationColumnNames.relatedEntityId: relatedEntityId,
        });
  }
}
