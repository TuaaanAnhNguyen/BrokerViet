// lib/widgets/profile/profile_summary_card.dart

import 'package:flutter/material.dart';

import 'profile_avatar_picker.dart';

class ProfileSummaryCard extends StatelessWidget {
  final String avatarPath;
  final String username;
  final String roleDisplay;
  final VoidCallback onAvatarTap;

  const ProfileSummaryCard({
    super.key,
    required this.avatarPath,
    required this.username,
    required this.roleDisplay,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004AC6);
    const darkText = Color(0xFF0B1C30);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          ProfileAvatarPicker(avatarPath: avatarPath, onTap: onAvatarTap),

          const SizedBox(height: 16),

          Text(
            username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              roleDisplay,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
