// lib/services/chat/chat_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  String get currentUserId => _client.auth.currentUser?.id ?? '';

  Future<String> getOrCreateChatRoom({
    required String providerId,
    required String customerId,
  }) async {
    final response = await _client.functions.invoke(
      'fetch-chats',
      method: HttpMethod.post,
      queryParameters: {'action': 'get_or_create'},
      body: {'customer_id': customerId, 'provider_id': providerId},
    );
    final data = response.data as Map<String, dynamic>;
    return data['chatroom_id']?.toString() ?? '';
  }

  Future<List<Map<String, dynamic>>> fetchChatRooms() async {
    final uid = currentUserId;
    if (uid.isEmpty) return [];

    try {
      final response = await _client.functions.invoke(
        'fetch-chats',
        method: HttpMethod.get,
        queryParameters: {'action': 'list', 'user_id': uid},
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> rawRooms = data['chatrooms'] ?? [];

      return rawRooms.map((room) {
        final map = room as Map<String, dynamic>;
        return {
          'chatroom_id': map['chatroom_id'],
          'target_name': map['target_name'] ?? 'Người dùng BrokerViet',
          'target_role': map['target_role'] ?? 'Thành viên',
          'avatar_url': map['avatar_url'],
          'last_message': map['last_message'],
          'time': map['sent_at'] != null ? _parseTimestamp(map['sent_at']) : '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching chat rooms via Edge Function: $e");
      return [];
    }
  }

  RealtimeChannel subscribeToChatChanges(Function onUpdate) {
    final channel = _client.channel('public:messages_changes');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            print('Realtime message update received!');
            onUpdate();
          },
        )
        .subscribe();

    return channel;
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
    if (cleanText.isEmpty || currentUserId.isEmpty) return;

    await _client.functions.invoke(
      'fetch-chats',
      method: HttpMethod.post,
      queryParameters: {'action': 'send'},
      body: {
        'chatroom_id': chatroomId,
        'sender_id': currentUserId,
        'content': cleanText,
      },
    );
  }

  String _parseTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
