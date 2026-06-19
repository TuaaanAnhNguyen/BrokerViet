// lib/features/chat/conversation_screen.dart

import 'package:flutter/material.dart';
import '../../services/chat/chat_service.dart';
import '../../widgets/avatar_builder.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            buildAvatar(
              (widget.avatarUrl == null || widget.avatarUrl == 'null')
                  ? ''
                  : widget.avatarUrl!,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.providerName,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.providerRole,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: bodyText),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
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

                    return _buildChatBubble(
                      msg['content'] ?? '',
                      _parseMessageTime(msg['sent_at']),
                      isMe,
                      primaryColor,
                      darkText,
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: primaryColor,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: bodyText),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(fontSize: 14, color: darkText),
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F3F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    String text,
    String time,
    bool isMe,
    Color primary,
    Color dark,
  ) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 16),
          ),
          border: isMe ? null : Border.all(color: const Color(0xFFE2E4EB)),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : dark,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black38,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
