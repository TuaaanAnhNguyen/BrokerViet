// lib/widgets/notification_tile.dart

import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final IconData iconType;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    required this.iconType,
  });
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade200
              : Colors.blue.shade100,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey.shade100
              : Colors.blue.shade50,
          child: Icon(
            notification.iconType,
            color: notification.isRead ? Colors.grey : Colors.blue,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                style: const TextStyle(color: Colors.black45, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                "${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')} - ${notification.createdAt.day}/${notification.createdAt.month}",
                style: const TextStyle(color: Colors.black38, fontSize: 11),
              ),
            ],
          ),
        ),
        trailing: !notification.isRead
            ? const Icon(Icons.circle, size: 10, color: Colors.blue)
            : null,
      ),
    );
  }
}
