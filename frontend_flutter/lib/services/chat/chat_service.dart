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

  // === FETCH CHAT ROOMS (via Edge Function) ===
  Future<List<Map<String, dynamic>>> fetchChatRooms() async {
    final uid = currentUserId;
    if (uid.isEmpty) return [];

    try {
      final response = await _client.functions.invoke(
        'list-chatrooms',
        method: HttpMethod.get,
        queryParameters: {'user_id': uid},
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> rawRooms = data['chatrooms'] ?? [];

      return rawRooms.map((room) {
        final map = room as Map<String, dynamic>;
        return {
          'chatroom_id': map['chatroom_id'],
          'target_name': map['target_name'] ?? 'Người dùng',
          'target_role': map['target_role'] ?? 'Thành viên',
          'avatar_url': map['avatar_url'],
          'last_message': map['last_message'],
          'sent_at': map['sent_at'],
          'time': map['sent_at'] != null ? _parseTimestamp(map['sent_at']) : '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching chat rooms: $e");
      return [];
    }
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
