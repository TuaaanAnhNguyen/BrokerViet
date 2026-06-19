// lib/features/chat/chat_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/chat/chat_service.dart';
import 'conversation_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/avatar_builder.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  RealtimeChannel? _chatSubscription;
  late Future<List<Map<String, dynamic>>> _chatRoomsFuture;

  @override
  void initState() {
    super.initState();
    _refreshChats();

    _chatSubscription = _chatService.subscribeToChatChanges(() {
      if (mounted) {
        _refreshChats();
      }
    });
  }

  void _refreshChats() {
    setState(() {
      _chatRoomsFuture = _chatService.fetchChatRooms();
    });
  }

  @override
  void dispose() {
    if (_chatSubscription != null) {
      Supabase.instance.client.removeChannel(_chatSubscription!);
    }
    super.dispose();
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: _refreshChats,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chatRoomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Không có cuộc hội thoại nào.',
                style: TextStyle(color: bodyText),
              ),
            );
          }

          final chatRooms = snapshot.data!;

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              final String targetName = room['target_name'] ?? '';
              final String? avatarUrl = room['avatar_url'];

              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationScreen(
                        chatroomId: room['chatroom_id'],
                        providerName: targetName,
                        providerRole: room['target_role'] ?? '',
                        avatarUrl: avatarUrl,
                      ),
                    ),
                  );
                  _refreshChats();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      buildAvatar(
                        (avatarUrl == null || avatarUrl == 'null')
                            ? ''
                            : avatarUrl,
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              targetName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkText,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room['last_message'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: bodyText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        room['time'] ?? '',
                        style: const TextStyle(fontSize: 11, color: bodyText),
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
}
