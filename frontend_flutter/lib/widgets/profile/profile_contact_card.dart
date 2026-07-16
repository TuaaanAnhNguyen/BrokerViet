// lib/widgets/profile/profile_contact_card.dart

import 'package:flutter/material.dart';

class ProfileContactCard extends StatelessWidget {
  final String phone;
  final String email;
  final String address;

  const ProfileContactCard({
    super.key,
    required this.phone,
    required this.email,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileRow(label: "Số điện thoại", value: phone),
        _ProfileRow(label: "Email", value: email),
        _ProfileRow(label: "Địa chỉ", value: address, showDivider: false),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _ProfileRow({
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
