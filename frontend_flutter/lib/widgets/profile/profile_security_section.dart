// lib/widgets/profile/profile_security_section.dart

import 'package:flutter/material.dart';
import 'account_setting_tile.dart';

class ProfileSecuritySection extends StatelessWidget {
  final VoidCallback onChangePassword;

  const ProfileSecuritySection({super.key, required this.onChangePassword});

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
        _header("Bảo mật tài khoản"),
        AccountSettingTile(
          icon: Icons.lock_outline_rounded,
          title: "Thay đổi mật khẩu",
          subtitle: "Cập nhật mật khẩu định kỳ để bảo vệ tài khoản",
          onTap: onChangePassword,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
