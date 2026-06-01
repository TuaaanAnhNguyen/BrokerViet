// lib/features/chat/conversation_screen.dart

import 'package:flutter/material.dart';

class ChatMessageModel {
  final String text;
  final String timestamp;
  final bool isMe;

  const ChatMessageModel({
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class ConversationScreen extends StatefulWidget {
  final String providerName;
  final String providerRole;
  final String? serviceContext;

  const ConversationScreen({
    super.key,
    required this.providerName,
    required this.providerRole,
    this.serviceContext,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessageModel> _messages = [
    const ChatMessageModel(
      text: "Xin chào! Tôi có thể giúp gì cho bạn về dịch vụ vệ sinh máy lạnh ạ?",
      timestamp: "10:30 AM",
      isMe: false,
    ),
    const ChatMessageModel(
      text: "Chào anh, phòng mình xài máy lạnh treo tường Daikin 1.5 HP, dạo này bật tầm 30 phút mới thấy mát với hơi có mùi ẩm á.",
      timestamp: "10:32 AM",
      isMe: true,
    ),
    const ChatMessageModel(
      text: "Dạ hiện tượng này thường do lưới lọc bị bám bụi dày dặn hoặc máng nước có chút nhớt tích tụ bẩn á anh. Gói 'Deep Cleaning' bên em sẽ xử lý triệt để xịt rửa dàn lạnh, dàn nóng và thông máng thoát nước luôn ạ.",
      timestamp: "10:35 AM",
      isMe: false,
    ),
    const ChatMessageModel(
      text: "Dạ vâng, em vừa bấm đặt lịch trên app vào lúc 2:30 PM chiều nay luôn rồi á, không biết bên mình sắp xếp kỹ thuật viên qua kịp không?",
      timestamp: "10:36 AM",
      isMe: true,
    ),
    const ChatMessageModel(
      text: "Dạ em đã nhận được yêu cầu trên hệ thống BrokerViet rồi nha anh! Kỹ thuật viên đang chuẩn bị dụng cụ và sẽ di chuyển qua Landmark 81 đúng khung giờ 2:30 PM của anh ạ.",
      timestamp: "10:38 AM",
      isMe: false,
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(
        ChatMessageModel(
          text: _messageController.text.trim(),
          timestamp: "10:40 AM",
          isMe: true,
        ),
      );
    });
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
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
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE5EEFF),
              child: Text(
                widget.providerName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.providerName,
                    style: const TextStyle(color: darkText, fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.providerRole,
                    style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined, color: primaryColor), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: bodyText), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: outlineVariant.withOpacity(0.5), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Optional Context Info Banner above conversation flow
          if (widget.serviceContext != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFEFF4FF),
              child: Row(
                children: [
                  const Icon(Icons.build_circle_outlined, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đang trao đổi về: ${widget.serviceContext}',
                      style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Message Bubble List Stream Area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message, primaryColor, darkText);
              },
            ),
          ),

          // Bottom Interactive Action Text Bar Input Block
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: primaryColor),
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
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildChatBubble(ChatMessageModel message, Color primary, Color dark) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 2),
            bottomRight: Radius.circular(message.isMe ? 2 : 16),
          ),
          border: message.isMe ? null : Border.all(color: const Color(0xFFE2E4EB)),
          boxShadow: [
            if (!message.isMe)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : dark,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                message.timestamp,
                style: TextStyle(
                  color: message.isMe ? Colors.white70 : Colors.black38,
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