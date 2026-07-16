// lib/widgets/profile/profile_avatar_picker.dart

import 'package:flutter/material.dart';

import '../avatar_builder.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final String avatarPath;
  final VoidCallback onTap;

  const ProfileAvatarPicker({
    super.key,
    required this.avatarPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004AC6);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          buildAvatar(
            avatarPath,
            radius: 46,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}