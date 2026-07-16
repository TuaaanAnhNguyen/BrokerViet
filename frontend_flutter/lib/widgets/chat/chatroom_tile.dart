// lib/widgets/chat/chatroom_tile.dart

import 'package:flutter/material.dart';
import '../../../widgets/avatar_builder.dart';

class ChatRoomTile extends StatelessWidget {
  final Map<String, dynamic> room;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatRoomTile({
    super.key,
    required this.room,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);

    final String targetName = room['target_name'] ?? 'Người dùng';
    final String? avatarUrl = room['avatar_url'];
    final String lastSenderId = room['last_sender_id'] ?? '';
    final String rawLastMessage = room['last_message'] ?? '';

    // Xử lý tiền tố tin nhắn cuối cùng
    String displayMessage = rawLastMessage;
    if (rawLastMessage.isNotEmpty && lastSenderId == currentUserId) {
      displayMessage = 'Bạn: $rawLastMessage';
    }

    final int unreadCount = room['unread_count'] ?? 0;
    final bool isUnread = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Avatar người nhận
            buildAvatar(avatarUrl ?? '', radius: 24),
            const SizedBox(width: 12),
            
            // Thông tin tên & tin nhắn cuối
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    targetName,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: darkText,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread ? Colors.black : bodyText,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Thời gian & Badge đếm tin nhắn chưa đọc
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  room['sent_at'] != null ? _formatTime(room['sent_at']) : '',
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnread ? primaryColor : bodyText,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 6),
                  _buildUnreadBadge(unreadCount, primaryColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tách widget con siêu nhỏ: Badge hiển thị tin nhắn chưa đọc
  Widget _buildUnreadBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatTime(dynamic isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}