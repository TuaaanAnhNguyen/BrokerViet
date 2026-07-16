// lib/widgets/profile/profile_provider_card.dart

import 'package:flutter/material.dart';

import '../../models/profile_model.dart';

class ProfileProviderCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileProviderCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProviderRow(
          label: "Giờ hoạt động",
          value:
              "${profile.openingHour ?? "--:--"} - ${profile.closingHour ?? "--:--"}",
        ),

        _ProviderRow(
          label: "Vị trí",
          value: profile.locationText ?? "Chưa cấu hình",
        ),

        _ProviderRow(
          label: "Payout",
          value: profile.payoutAccountNumber == null
              ? "Chưa liên kết ngân hàng"
              : "[${profile.payoutBankCode ?? "Bank"}] ${profile.payoutAccountNumber}",
          showDivider: false,
        ),
      ],
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _ProviderRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFF1F3F6), width: .5),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7E84A2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0B1C30),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
