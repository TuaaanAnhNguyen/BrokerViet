// lib/widgets/profile/profile_danger_section.dart
import 'package:flutter/material.dart';

class ProfileDangerSection extends StatelessWidget {
  final VoidCallback onDelete;

  const ProfileDangerSection({super.key, required this.onDelete});

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
        _header("Vùng nguy hiểm"),

        Container(
          color: Colors.white,
          child: ListTile(
            leading: Icon(
              Icons.delete_forever_rounded,
              color: Colors.red.shade700,
            ),
            title: Text(
              "Yêu cầu xóa tài khoản",
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text("Xóa vĩnh viễn dữ liệu profile khỏi hệ thống"),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFC3C6D7),
            ),
            onTap: onDelete,
          ),
        ),
      ],
    );
  }
}
