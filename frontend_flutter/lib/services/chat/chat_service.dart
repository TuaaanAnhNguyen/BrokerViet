// lib/services/chat/chat_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  String get currentUserId => _client.auth.currentUser?.id ?? '';

  Future<String> getOrCreateChatRoom({
    required String providerId,
    required String customerId,
  }) async {
    if (customerId.isEmpty || providerId.isEmpty) {
      throw Exception('ID người dùng không hợp lệ.');
    }

    final existingRoom = await _client
        .from('chatrooms')
        .select('chatroom_id')
        .eq('customer_id', customerId)
        .eq('provider_id', providerId)
        .maybeSingle();

    if (existingRoom != null) {
      final chatroomId = existingRoom['chatroom_id'] as String;
      
      return chatroomId;
    }

    final newRoomRes = await _client.from('chatrooms').insert({
      'customer_id': customerId,
      'provider_id': providerId,
    }).select('chatroom_id').single();

    return newRoomRes['chatroom_id'] as String;
  }

  Stream<List<Map<String, dynamic>>> streamChatRooms() {
    return _client
        .from('chatrooms')
        .stream(primaryKey: ['chatroom_id'])
        .asyncMap((rooms) async {
          final hydratedRooms = <Map<String, dynamic>>[];

          for (var room in rooms) {
            final String customerId = room['customer_id'] ?? '';
            final String providerId = room['provider_id'] ?? '';
            final String chatroomId = room['chatroom_id'];

            final bool isCustomer = customerId == currentUserId;
            final String targetUserId = isCustomer ? providerId : customerId;

            final profileRes = await _client
                .from('profiles')
                .select('username, role, avatar_url')
                .eq('user_id', targetUserId)
                .maybeSingle();

            final lastMsgRes = await _client
                .from('messages')
                .select('content, sent_at')
                .eq('chatroom_id', chatroomId)
                .order('sent_at', ascending: false)
                .limit(1)
                .maybeSingle();

            hydratedRooms.add({
              'chatroom_id': chatroomId,
              'target_name': profileRes?['username'] ?? 'Người dùng BrokerViet',
              'target_role': profileRes?['role'] ?? 'Thành viên',
              'avatar_url': profileRes?['avatar_url'],
              'last_message': lastMsgRes?['content'] ?? 'Chưa có tin nhắn nào.',
              'time': lastMsgRes?['sent_at'] != null 
                  ? _parseTimestamp(lastMsgRes!['sent_at']) 
                  : '',
              'unread_count': 0,
            });
          }
          return hydratedRooms;
        });
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String chatroomId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['message_id'])
        .eq('chatroom_id', chatroomId)
        .order('sent_at', ascending: true);
  }

  Future<void> sendMessage(String chatroomId, String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await _client.from('messages').insert({
      'chatroom_id': chatroomId,
      'sender_id': currentUserId,
      'content': cleanText,
      'sent_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  String _parseTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }
}