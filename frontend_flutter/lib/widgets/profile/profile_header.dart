// lib/widgets/profile/profile_header.dart

import 'package:flutter/material.dart';
import '../avatar_builder.dart';

class ProfileHeader extends StatelessWidget {
  final String avatarPath;
  final String username;
  final String roleDisplay;

  const ProfileHeader({
    super.key,
    required this.avatarPath,
    required this.username,
    required this.roleDisplay,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          buildAvatar(avatarPath),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roleDisplay,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
