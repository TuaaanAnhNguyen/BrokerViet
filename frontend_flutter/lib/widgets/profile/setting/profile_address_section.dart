// lib/widgets/profile/profile_address_section.dart

import 'package:flutter/material.dart';
import '../../../models/profile_model.dart';
import 'account_setting_tile.dart';

class ProfileAddressSection extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEdit;

  const ProfileAddressSection({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionHeader('Địa chỉ'),

        AccountSettingTile(
          icon: Icons.map_outlined,
          title: 'Địa chỉ & Tọa độ bản đồ',
          subtitle:
              profile.locationText ?? profile.address ?? 'Chưa xác định vị trí',
          onTap: onEdit,
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sectionHeader(String title) {
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
}
