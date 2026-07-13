// lib/widgets/profile/profile_contact_section.dart

import 'package:flutter/material.dart';
import 'account_setting_tile.dart';

class ProfileContactSection extends StatelessWidget {
  final String email;
  final String phone;
  final VoidCallback onChangeEmail;

  const ProfileContactSection({
    super.key,
    required this.email,
    required this.phone,
    required this.onChangeEmail,
  });

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF7E84A2),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: .5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header("Thông tin liên hệ"),

        AccountSettingTile(
          icon: Icons.email_outlined,
          title: "Thay đổi Email",
          subtitle: email,
          onTap: onChangeEmail,
        ),

        AccountSettingTile(
          icon: Icons.phone_android_rounded,
          title: "Số điện thoại đăng nhập",
          subtitle: phone,
          onTap: () {},
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
