// lib/services/chat/chat_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../notification/notification_service.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

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

    final newRoomRes = await _client
        .from('chatrooms')
        .insert({'customer_id': customerId, 'provider_id': providerId})
        .select('chatroom_id')
        .single();

    return newRoomRes['chatroom_id'] as String;
  }

  Future<List<Map<String, dynamic>>> fetchChatRooms() async {
    final uid = currentUserId;
    if (uid.isEmpty) return [];

    try {
      final List<dynamic> rooms = await _client
          .from('chatrooms')
          .select()
          .or('customer_id.eq.$uid,provider_id.eq.$uid');

      final hydratedRooms = <Map<String, dynamic>>[];

      for (var room in rooms) {
        final String customerId = room['customer_id'] ?? '';
        final String providerId = room['provider_id'] ?? '';
        final String chatroomId = room['chatroom_id'];

        final bool isCustomer = customerId == uid;
        final String targetUserId = isCustomer ? providerId : customerId;

        if (targetUserId.isEmpty) continue;

        // Đọc thông tin đối phương
        final profileRes = await _client
            .from('profiles')
            .select('username, role, avatar_url')
            .eq('user_id', targetUserId)
            .maybeSingle();

        // Đọc tin nhắn cuối cùng
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
    } catch (e) {
      print("Lỗi Fetch Phòng Chat: $e");
      return [];
    }
  }

  RealtimeChannel subscribeToChatChanges(Function onUpdate) {
    final uid = currentUserId;

    final channel = _client.channel('public:messages');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            onUpdate();
          },
        )
        .subscribe();

    return channel;
  }

  String _parseTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
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

    try {
      final roomRes = await _client
          .from('chatrooms')
          .select('customer_id, provider_id')
          .eq('chatroom_id', chatroomId)
          .single();
      
      final customerId = roomRes['customer_id'] as String;
      final providerId = roomRes['provider_id'] as String;
      final recipientId = (currentUserId == customerId) ? providerId : customerId;

      final senderProfile = await _client
          .from('profiles')
          .select('username')
          .eq('user_id', currentUserId)
          .maybeSingle();
      
      final senderName = senderProfile?['username'] ?? 'Người dùng';

      await _notificationService.createNotification(
        userId: recipientId,
        title: 'Tin nhắn mới từ $senderName',
        content: cleanText,
      );
    } catch (e) {
      print('Error sending message notification: $e');
    }
  }

  // String _parseTimestamp(String isoString) {
  //   try {
  //     final dateTime = DateTime.parse(isoString).toLocal();
  //     final hour = dateTime.hour.toString().padLeft(2, '0');
  //     final minute = dateTime.minute.toString().padLeft(2, '0');
  //     return '$hour:$minute';
  //   } catch (_) {
  //     return '';
  //   }
  // }
}
