// lib/services/chat/chat_service.dart

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  String get currentUserId => _client.auth.currentUser?.id ?? '';

  // === STREAM CHAT ROOMS (via Edge Function + Realtime refresh) ===
  Stream<List<Map<String, dynamic>>> streamChatRooms() {
    final controller = StreamController<List<Map<String, dynamic>>>();

    final uid = currentUserId;

    if (uid.isEmpty) {
      controller.add([]);
      controller.close();
      return controller.stream;
    }

    Future<void> refresh() async {
      final rooms = await fetchChatRooms();
      controller.add(rooms);
    }

    refresh();

    final channel = _client
        .channel('chat_list_changes_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chatrooms',
          callback: (payload) async {
            print("CHATROOM EVENT");
            print(payload);
            await refresh();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) async {
            print("MESSAGE EVENT");
            print(payload);
            await refresh();
          },
        );

    channel.subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> fetchChatRooms() async {
    final uid = currentUserId;

    if (uid.isEmpty) return [];

    try {
      final rooms = await _client
          .from('chatrooms')
          .select()
          .or('customer_id.eq.$uid,provider_id.eq.$uid');

      return List<Map<String, dynamic>>.from(rooms);
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String chatroomId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['message_id'])
        .eq('chatroom_id', chatroomId)
        .order('sent_at')
        .map(
          (rows) => rows
              .map(
                (row) => {
                  'message_id': row['message_id'],
                  'sender_id': row['sender_id'],
                  'content': row['content'],
                  'sent_at': row['sent_at'],
                },
              )
              .toList(),
        );
  }

  // === GET OR CREATE CHATROOM ===
  Future<String> getOrCreateChatRoom({
    required String providerId,
    required String customerId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'get-or-create-chatroom',
        method: HttpMethod.post,
        body: {'customer_id': customerId, 'provider_id': providerId},
      );
      final data = response.data as Map<String, dynamic>;
      return data['chatroom_id']?.toString() ?? '';
    } catch (e) {
      print("Error getOrCreateChatRoom: $e");
      return '';
    }
  }

  // === SEND MESSAGE ===
  Future<void> sendMessage(String chatroomId, String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || currentUserId.isEmpty) return;

    await _client.functions.invoke(
      'send-message',
      method: HttpMethod.post,
      body: {
        'chatroom_id': chatroomId,
        'sender_id': currentUserId,
        'content': cleanText,
      },
    );
  }

  String _parseTimestamp(dynamic isoString) {
    if (isoString == null) return '';
    try {
      final dateTime = DateTime.parse(isoString.toString()).toLocal();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
