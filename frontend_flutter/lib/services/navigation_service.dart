// lib/services/navigation_service.dart

import 'package:flutter/material.dart';
import '../features/chat/conversation_screen.dart';
import '../features/main/notification_screen.dart';
import './chat/chat_service.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> handleNotification(Map<String, dynamic> data) async {
    final navigator = navigatorKey.currentState;

    if (navigator == null) return;

    final type = data["type"]?.toString() ?? "";
    final referenceId = data["reference_id"]?.toString() ?? "";

    switch (type) {
      case "CHAT":
        if (referenceId.isEmpty) return;

        try {
          final detail = await ChatService().getChatroomDetail(referenceId);

          navigator.push(
            MaterialPageRoute(
              builder: (_) => ConversationScreen(
                chatroomId: detail["chatroom_id"],
                providerName: detail["other_username"] ?? "",
                providerRole: detail["other_role"] ?? "",
                avatarUrl: detail["other_avatar"],
              ),
            ),
          );
        } catch (e) {
          debugPrint("Failed opening chat: $e");
        }

        break;

      default:
        navigator.push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
    }
  }
}
