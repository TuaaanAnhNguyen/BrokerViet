// lib/widgets/profile/account_setting_tile.dart

import 'package:flutter/material.dart';

class AccountSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AccountSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F3F6), width: 0.5),
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF004AC6), size: 22),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B1C30),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF7E84A2), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFFC3C6D7),
              ),
          onTap: trailing == null ? onTap : null,
        ),
      ),
    );
  }
}