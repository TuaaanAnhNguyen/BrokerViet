// lib/widgets/chat/chat_bubble.dart

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final Color primaryColor;
  final Color darkText;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    required this.primaryColor,
    required this.darkText,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        color: isMe ? primaryColor : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        border: isMe ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            text,
            softWrap: true,
            style: TextStyle(
              color: isMe ? Colors.white : darkText,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: isMe ? Colors.white70 : Colors.black45,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [Flexible(child: bubble)],
      ),
    );
  }
}
