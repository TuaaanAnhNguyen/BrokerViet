// lib/models/notification_model.dart

class NotificationModel {
  final String notification_id;
  final String user_id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.notification_id,
    required this.user_id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notification_id: notification_id,
      user_id: user_id,
      title: title,
      content: content,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}