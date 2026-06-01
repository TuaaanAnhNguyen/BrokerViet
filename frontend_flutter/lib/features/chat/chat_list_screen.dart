// lib/features/chat/chat_list_screen.dart

import 'package:flutter/material.dart';

class ChatSummaryModel {
  final String providerName;
  final String lastMessage;
  final String time;
  final int unreadCount;

  const ChatSummaryModel({
    required this.providerName,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  final List<ChatSummaryModel> _mockChats = const [
    ChatSummaryModel(providerName: 'TechCare Da Nang', lastMessage: 'Sure, you can bring your PC over around 2 PM.', time: '10:42 AM', unreadCount: 2),
    ChatSummaryModel(providerName: 'Minh Triet Computer', lastMessage: 'Your operating system patch is fully ready.', time: 'Yesterday'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemCount: _mockChats.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final chat = _mockChats[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(chat.providerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: chat.unreadCount > 0 ? Colors.black38 : Colors.black54),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat.time, style: const TextStyle(fontSize: 12, color: Colors.black38)),
                const SizedBox(height: 4),
                if (chat.unreadCount > 0)
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.blue,
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}