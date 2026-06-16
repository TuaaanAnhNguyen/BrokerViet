// lib/features/chat/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'conversation_screen.dart'; // Import to link navigation target

class ChatSummaryModel {
  final String providerName;
  final String providerRole; // Added to map context to ConversationScreen
  final String lastMessage;
  final String time;
  final int unreadCount;

  const ChatSummaryModel({
    required this.providerName,
    required this.providerRole,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  final List<ChatSummaryModel> _mockChats = const [
    ChatSummaryModel(
      providerName: 'TechCare Pro Service',
      providerRole: 'Đơn vị sửa chữa máy tính',
      lastMessage:
          'Dạ vâng, anh mang máy qua lúc 2:30 chiều nay là kỹ thuật viên xử lý luôn được ạ.',
      time: '10:42 AM',
      unreadCount: 2,
    ),
    ChatSummaryModel(
      providerName: 'An Phát Computer',
      providerRole: 'Nhà phân phối linh kiện',
      lastMessage:
          'Sản phẩm bàn phím cơ của anh đã có hàng sẵn tại chi nhánh rồi nhé ạ.',
      time: 'Hôm qua',
    ),
    ChatSummaryModel(
      providerName: 'Blood Lab Center',
      providerRole: 'Trung tâm xét nghiệm y khoa',
      lastMessage:
          'Kết quả đánh giá chỉ số xét nghiệm lâm sàng của anh đã được cập nhật trên hệ thống.',
      time: '25 Th05',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Standard platform design color tokens matching BrokerViet
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
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: _mockChats.isEmpty
          ? const Center(
              child: Text(
                'Không có cuộc hội thoại nào.',
                style: TextStyle(color: bodyText),
              ),
            )
          : ListView.separated(
              itemCount: _mockChats.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 76,
                color: outlineVariant.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final chat = _mockChats[index];
                final hasUnread = chat.unreadCount > 0;

                return InkWell(
                  onTap: () {
                    // Smooth navigation routing directly into your conversation panel layout
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          providerName: chat.providerName,
                          providerRole: chat.providerRole,
                          serviceContext: index == 0
                              ? "Deep PC Cleaning"
                              : null, // Mocks context tagging
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Left Profile Circle Icon
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFEFF4FF),
                          child: Text(
                            chat.providerName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Middle Content Text Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.providerName,
                                style: TextStyle(
                                  fontWeight: hasUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 15,
                                  color: darkText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: hasUnread
                                      ? darkText.withValues(alpha: 0.85)
                                      : bodyText,
                                  fontSize: 13,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Right Status Meta Column (Timestamp + Unread Indicator)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              chat.time,
                              style: TextStyle(
                                fontSize: 11,
                                color: hasUnread
                                    ? primaryColor
                                    : bodyText.withValues(alpha: 0.6),
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (hasUnread)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Center(
                                  child: Text(
                                    chat.unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(
                                height: 18,
                              ), // Visual spacer layout anchor
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
