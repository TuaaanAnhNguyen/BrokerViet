// lib/widgets/chat/chat_app_bar.dart

import 'package:flutter/material.dart';
import '../avatar_builder.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String providerName;
  final String providerRole;
  final String? avatarUrl;
  final VoidCallback onBackPressed;
  final Color primaryColor;
  final Color darkText;
  final Color outlineVariant;

  const ChatAppBar({
    super.key,
    required this.providerName,
    required this.providerRole,
    this.avatarUrl,
    required this.onBackPressed,
    required this.primaryColor,
    required this.darkText,
    required this.outlineVariant,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: primaryColor),
        onPressed: onBackPressed,
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          buildAvatar(
            (avatarUrl == null || avatarUrl == 'null') ? '' : avatarUrl!,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  providerName,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  providerRole,
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
      actions: const [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: outlineVariant.withAlpha(127), height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
