// lib/models/notification_model.dart

enum NotificationType { CHAT, BOOKING, PAYMENT }

class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType? type;
  final String? referenceId;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.referenceId,
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
      type: map['type'] == null
          ? null
          : NotificationType.values.byName(map['type']),
      referenceId: map['reference_id']?.toString(),
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
      'type': type?.name,
      'reference_id': referenceId,
    };
  }

  NotificationModel copyWith({
    bool? isRead,
    NotificationType? type,
    String? referenceId,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      content: content,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}
