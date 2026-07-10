// lib/features/chat/chat_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/chat/chat_service.dart';
import 'conversation_screen.dart';
import '../../widgets/avatar_builder.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.streamChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final chatRooms = snapshot.data ?? [];

          if (chatRooms.isEmpty) {
            return const Center(
              child: Text(
                'Không có cuộc hội thoại nào.',
                style: TextStyle(color: bodyText),
              ),
            );
          }

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              final String targetName = room['target_name'] ?? 'Người dùng';
              final String? avatarUrl = room['avatar_url'];

              final String lastSenderId = room['last_sender_id'] ?? '';
              final String rawLastMessage = room['last_message'] ?? '';

              String displayMessage = rawLastMessage;
              if (rawLastMessage.isNotEmpty &&
                  lastSenderId == _chatService.currentUserId) {
                displayMessage = 'Bạn: $rawLastMessage';
              }

              final int unreadCount = room['unread_count'] ?? 0;
              final bool isUnread = unreadCount > 0;

              return InkWell(
                onTap: () async {
                  if (isUnread) {
                    _chatService.markAsRead(room['chatroom_id']);
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(
                        chatroomId: room['chatroom_id'],
                        providerName: targetName,
                        providerRole: room['target_role'] ?? '',
                        avatarUrl: avatarUrl,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      buildAvatar(avatarUrl ?? '', radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              targetName,
                              style: TextStyle(
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: darkText,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isUnread ? Colors.black : bodyText,
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            room['sent_at'] != null
                                ? _formatTime(room['sent_at'])
                                : '',
                            style: TextStyle(
                              fontSize: 11,
                              color: isUnread ? primaryColor : bodyText,
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(minWidth: 20),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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