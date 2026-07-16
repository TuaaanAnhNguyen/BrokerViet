// lib/widgets/profile/profile_edit_button.dart

import 'package:flutter/material.dart';

class ProfileEditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ProfileEditButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
        label: const Text(
          "Chỉnh sửa thông tin cá nhân",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
