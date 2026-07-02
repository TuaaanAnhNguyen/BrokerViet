// lib/services/notification/notification_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _client = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initRealtimeNotificationListener();
  }

  void _initRealtimeNotificationListener() {
    final userId = _client.auth.currentSession?.user.id;
    if (userId == null) return;

    // Listen to real-time INSERT database modifications specifically for this user
    _client
        .channel('public:notifications:user_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Extract text fields straight from the raw database row payload map
            final String title =
                payload.newRecord['title'] ?? 'BrokerViet Update';
            final String content = payload.newRecord['content'] ?? '';

            // Push it to the device system UI drawer instantly
            _showLocalNotificationBanner(title, content);
          },
        )
        .subscribe();
  }

  Future<void> _showLocalNotificationBanner(
    String title,
    String content,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important broker and chat updates.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Generate an ID for the alert banner item slot
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // FIX: Swapped positional arguments for named parameters required by version 22+
    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: content,
      notificationDetails: platformDetails,
    );
  }

  // Get notifications for current user
  Future<List<NotificationModel>> getNotifications() async {
    final userId = _client.auth.currentSession?.user.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => NotificationModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Stream notifications for real-time updates
  Stream<List<NotificationModel>> streamNotifications() {
    final userId = _client.auth.currentSession?.user.id;
    if (userId == null) return Stream.value([]);

    return _client
        .from('notifications')
        .stream(primaryKey: ['notification_id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data.map((json) => NotificationModel.fromMap(json)).toList(),
        );
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('notification_id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentSession?.user.id;
    if (userId == null) return;

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('notification_id', notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Create a new notification (usually called by backend, but useful for client-side triggers in this project)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      print('creating notification');
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'content': content,
        'is_read': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }
}
