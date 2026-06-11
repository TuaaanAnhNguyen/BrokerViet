// lib/widgets/notification_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  // Structural Theme Configurator mapping key operational updates
  Map<String, dynamic> _getStyleSpecs() {
    final titleLower = notification.title.toLowerCase();

    if (titleLower.contains('xử lý') || titleLower.contains('tiếp nhận')) {
      return {
        'label': 'TIẾP NHẬN',
        'icon': Icons.bolt_rounded, // High-energy, modern speed icon
        'brandColor': const Color(0xFF004AC6),
        'bgGradStart': const Color(0xFFF0F5FF),
        'bgGradEnd': const Color(0xFFE5EFFF),
      };
    } else if (titleLower.contains('chờ') || titleLower.contains('xác nhận')) {
      return {
        'label': 'XÁC NHẬN',
        'icon': Icons.hourglass_empty_rounded,
        'brandColor': const Color(0xFFF59E0B),
        'bgGradStart': const Color(0xFFFFFBEB),
        'bgGradEnd': const Color(0xFFFFF3CD),
      };
    } else if (titleLower.contains('hoàn thành') ||
        titleLower.contains('tất')) {
      return {
        'label': 'HOÀN THÀNH',
        'icon': Icons.auto_awesome_rounded, // Premium tech aesthetic flare
        'brandColor': const Color(0xFF10B981),
        'bgGradStart': const Color(0xFFECFDF5),
        'bgGradEnd': const Color(0xFFD1FAE5),
      };
    } else if (titleLower.contains('hủy')) {
      return {
        'label': 'HỦY ĐƠN',
        'icon': Icons.layers_clear_rounded,
        'brandColor': const Color(0xFFEF4444),
        'bgGradStart': const Color(0xFFFEF2F2),
        'bgGradEnd': const Color(0xFFFEE2E2),
      };
    }

    return {
      'label': 'CẬP NHẬT',
      'icon': Icons.gpp_good_rounded,
      'brandColor': const Color(0xFF6B7280),
      'bgGradStart': const Color(0xFFF9FAFB),
      'bgGradEnd': const Color(0xFFF3F4F6),
    };
  }

  // Helper utility to parse out specific order hash tokens from plain text bodies
  String? _extractOrderCode(String text) {
    final RegExp regExp = RegExp(r'#\[?[A-Z0-9\-]+\]?');
    final match = regExp.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final specs = _getStyleSpecs();
    final Color brandColor = specs['brandColor'];
    final String labelText = specs['label'];

    final String timeStr =
        "${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}";
    final String dateStr =
        "${notification.createdAt.day}/${notification.createdAt.month}";
    final String? orderCode = _extractOrderCode(notification.content);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          24,
        ), // Ultra-smooth modern curvature
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF0B1C30,
            ).withOpacity(notification.isRead ? 0.02 : 0.05),
            blurRadius: notification.isRead ? 12 : 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: brandColor.withOpacity(0.05),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER LAYER: Label Pill, Unread Dot, and Timestamp
                  Row(
                    children: [
                      // Modern, structured uppercase micro-tag badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? const Color(0xFFF3F4F6)
                              : brandColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          labelText,
                          style: TextStyle(
                            color: notification.isRead
                                ? const Color(0xFF6B7280)
                                : brandColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pulse Alert Indicator: Only visible on unread notifications
                      if (!notification.isRead)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: brandColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const Spacer(),
                      // Clean, modern text timestamp alignment
                      Text(
                        "$timeStr • $dateStr",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CORE BODY LAYER: Title & Descriptive Content Text Layout
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: const Color(0xFF0B1C30),
                      fontSize: 16,
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.content,
                    style: TextStyle(
                      color: notification.isRead
                          ? const Color(0xFF7E84A2)
                          : const Color(0xFF334155),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                  ),

                  // REVOLUTIONARY EXTRA FOOTER: Interactive Data-Chips
                  if (orderCode != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            size: 14,
                            color: Colors.blueGrey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Mã đơn: $orderCode',
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'Courier', // Gives it a tech/hardware tracking vibe
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: orderCode
                                      .replaceAll('[', '')
                                      .replaceAll(']', ''),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã sao chép mã đơn $orderCode',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: brandColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
