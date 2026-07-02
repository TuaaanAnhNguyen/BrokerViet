// lib/models/notification_model.dart

class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notification_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      content: content,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
