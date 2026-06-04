// lib/widgets/notification_tile.dart

import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String status; // 'In Review', 'In Progress', 'Done', 'Cancelled'

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    required this.status,
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

  // Map the strict string statuses to specialized thematic UI values
  Map<String, dynamic> _getStatusUiDetails(String status) {
    switch (status) {
      case 'In Review':
        return {
          'icon': Icons.rate_review_outlined,
          'color': const Color(0xFFF59E0B), // Warm Amber
          'fallbackColor': Colors.amber.shade50,
        };
      case 'In Progress':
        return {
          'icon': Icons.build_circle_outlined,
          'color': const Color(0xFF004AC6), // BrokerViet Primary Blue
          'fallbackColor': const Color(0xFFEFF4FF),
        };
      case 'Done':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'color': const Color(0xFF10B981), // Emerald Green
          'fallbackColor': Colors.green.shade50,
        };
      case 'Cancelled':
        return {
          'icon': Icons.cancel_outlined,
          'color': const Color(0xFFEF4444), // Crimson Red
          'fallbackColor': Colors.red.shade50,
        };
      default:
        return {
          'icon': Icons.notifications_none_outlined,
          'color': const Color(0xFF434655),
          'fallbackColor': Colors.grey.shade100,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiDetails = _getStatusUiDetails(notification.status);
    final IconData statusIcon = uiDetails['icon'];
    final Color activeColor = uiDetails['color'];
    final Color activeBgColor = uiDetails['fallbackColor'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : activeColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade200
              : activeColor.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey.shade100
              : activeBgColor,
          child: Icon(
            statusIcon,
            color: notification.isRead ? Colors.grey : activeColor,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            color: const Color(0xFF0B1C30),
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
                style: const TextStyle(color: Color(0xFF434655), fontSize: 13),
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
            ? Icon(Icons.circle, size: 10, color: activeColor)
            : null,
      ),
    );
  }
}