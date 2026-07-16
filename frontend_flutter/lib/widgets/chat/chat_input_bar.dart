// lib/widgets/chat/chat_input_bar.dart

import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Color primaryColor;
  final Color darkText;
  final Color outlineVariant;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.primaryColor,
    required this.darkText,
    required this.outlineVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: outlineVariant.withAlpha(127))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => onSend(),
              style: TextStyle(fontSize: 14, color: darkText),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
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
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send_rounded, color: primaryColor),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
