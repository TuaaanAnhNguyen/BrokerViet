// lib/features/chat/conversation_screen.dart

import 'package:flutter/material.dart';
import '../../services/chat/chat_service.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_app_bar.dart';
import '../../widgets/chat/chat_input_bar.dart';

class ConversationScreen extends StatefulWidget {
  final String chatroomId;
  final String providerName;
  final String providerRole;
  final String? avatarUrl;

  const ConversationScreen({
    super.key,
    required this.chatroomId,
    required this.providerName,
    required this.providerRole,
    this.avatarUrl,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  late final Stream<List<Map<String, dynamic>>> _messageStream;

  @override
  void initState() {
    super.initState();
    _messageStream = _chatService.streamMessages(widget.chatroomId);
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _chatService.sendMessage(widget.chatroomId, text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể gửi tin nhắn: $e')));
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _parseMessageTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: ChatAppBar(
        providerName: widget.providerName,
        providerRole: widget.providerRole,
        avatarUrl: widget.avatarUrl,
        onBackPressed: () => Navigator.pop(context),
        primaryColor: primaryColor,
        darkText: darkText,
        outlineVariant: outlineVariant,
      ),
      body: Column(
        children: [
          // Khu vực hiển thị tin nhắn
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messageStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Đã có lỗi xảy ra: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                // Cuộn xuống cuối sau khi dữ liệu được vẽ xong
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Hãy gửi lời chào đầu tiên!',
                      style: TextStyle(color: bodyText),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe =
                        msg['sender_id'] == _chatService.currentUserId;

                    return ChatBubble(
                      text: msg['content'] ?? '',
                      time: _parseMessageTime(msg['sent_at']),
                      isMe: isMe,
                      primaryColor: primaryColor,
                      darkText: darkText,
                    );
                  },
                );
              },
            ),
          ),

          ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
            primaryColor: primaryColor,
            darkText: darkText,
            outlineVariant: outlineVariant,
          ),
        ],
      ),
    );
  }
}
