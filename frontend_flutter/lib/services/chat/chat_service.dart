// lib/services/chat/chat_service.dart

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  String get currentUserId => _client.auth.currentUser?.id ?? '';

  // STREAM CHATROOMS
  Stream<List<Map<String, dynamic>>> streamChatRooms() {
    final controller = StreamController<List<Map<String, dynamic>>>();

    final uid = currentUserId;

    if (uid.isEmpty) {
      controller.add([]);
      controller.close();
      return controller.stream;
    }

    Future<void> refresh() async {
      try {
        final rooms = await fetchChatRooms();

        if (!controller.isClosed) {
          controller.add(rooms);
        }
      } catch (e) {
        print("Refresh error: $e");
      }
    }

    refresh();

    Timer? refreshTimer;

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => refresh(),
    );

    final channel = _client
        .channel('chat_list_changes_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chatrooms',
          callback: (_) async {
            print("Realtime -> chatrooms");
            await refresh();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (_) async {
            print("Realtime -> messages");
            await refresh();
          },
        );

    channel.subscribe();

    controller.onCancel = () {
      refreshTimer?.cancel();
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  // FETCH CHATROOMS
  Future<List<Map<String, dynamic>>> fetchChatRooms() async {
    final uid = currentUserId;

    if (uid.isEmpty) return [];

    try {
      final response = await _client.functions.invoke(
        'list-chatroom',
        method: HttpMethod.get,
        queryParameters: {'user_id': uid},
      );

      final data = response.data as Map<String, dynamic>;

      final List<dynamic> rooms = data['chatrooms'] ?? [];

      return rooms
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      print("fetchChatRooms error: $e");
      return [];
    }
  }

  // STREAM MESSAGES
  Stream<List<Map<String, dynamic>>> streamMessages(String chatroomId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['message_id'])
        .eq('chatroom_id', chatroomId)
        .map((rows) {
          rows.sort(
            (a, b) => DateTime.parse(
              a['sent_at'],
            ).compareTo(DateTime.parse(b['sent_at'])),
          );

          return rows
              .map(
                (row) => {
                  'message_id': row['message_id'],
                  'sender_id': row['sender_id'],
                  'content': row['content'],
                  'sent_at': row['sent_at'],
                },
              )
              .toList();
        });
  }

  // GET / CREATE CHATROOM
  Future<String> getOrCreateChatRoom({
    required String providerId,
    required String customerId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'get-or-create-chatroom',
        method: HttpMethod.post,
        body: {
          'customer_id': customerId,
          'provider_id': providerId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      return data['chatroom_id']?.toString() ?? '';
    } catch (e) {
      print(e);
      return '';
    }
  }

  // SEND MESSAGE
  Future<void> sendMessage(
    String chatroomId,
    String text,
  ) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty || currentUserId.isEmpty) return;

    await _client.functions.invoke(
      "send-message",
      method: HttpMethod.post,
      body: {
        "chatroom_id": chatroomId,
        "sender_id": currentUserId,
        "content": cleanText,
      },
    );
  }

  // MARK READ
  Future<void> markAsRead(String chatroomId) async {
    final uid = currentUserId;

    if (uid.isEmpty) return;

    try {
      await _client
          .from('chatrooms')
          .update({'customer_unread_count': 0})
          .eq('chatroom_id', chatroomId)
          .eq('customer_id', uid);

      await _client
          .from('chatrooms')
          .update({'provider_unread_count': 0})
          .eq('chatroom_id', chatroomId)
          .eq('provider_id', uid);
    } catch (e) {
      print(e);
    }
  }

  // DETAIL
  Future<Map<String, dynamic>> getChatroomDetail(
    String chatroomId,
  ) async {
    final response = await Supabase.instance.client.functions.invoke(
      'get-chatroom-detail',
      body: {
        'chatroom_id': chatroomId,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  String parseTimestamp(dynamic isoString) {
    if (isoString == null) return '';

    try {
      final dt = DateTime.parse(
        isoString.toString(),
      ).toLocal();

      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }
}