// lib/widgets/profile/profile_provider_section.dart

import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import 'account_setting_tile.dart';

class ProfileProviderSection extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEdit;

  const ProfileProviderSection({
    super.key,
    required this.profile,
    required this.onEdit,
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
        _header("Thông tin vận hành (Chỉ Đối Tác)"),

        AccountSettingTile(
          icon: Icons.storefront_outlined,
          title: "Cấu hình khung giờ hoạt động",
          subtitle:
              "Mở cửa: ${profile.openingHour ?? "Chưa thiết lập"} • Đóng cửa: ${profile.closingHour ?? "Chưa thiết lập"}",
          onTap: onEdit,
        ),

        AccountSettingTile(
          icon: Icons.account_balance_wallet_outlined,
          title: "Tài khoản ngân hàng nhận Payout",
          subtitle: profile.payoutAccountNumber != null
              ? "[${profile.payoutBankCode ?? "Ngân hàng"}] ${profile.payoutAccountNumber}"
              : "Chưa cấu hình tài khoản nhận doanh thu",
          onTap: onEdit,
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
