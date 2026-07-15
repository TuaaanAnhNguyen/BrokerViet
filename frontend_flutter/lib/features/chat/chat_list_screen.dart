// lib/features/chat/chat_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/chat/chat_service.dart';
import 'conversation_screen.dart';
import '../../widgets/chat/chatroom_tile.dart';

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
        elevation: 0, // Đổ bóng nhẹ cho App Bar hiện đại hơn
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
            return Center(
              child: Text('Lỗi tải cuộc hội thoại: ${snapshot.error}'),
            );
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
              final int unreadCount = room['unread_count'] ?? 0;
              final bool isUnread = unreadCount > 0;

              return ChatRoomTile(
                room: room,
                currentUserId: _chatService.currentUserId ?? '',
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
                        avatarUrl: room['avatar_url'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
