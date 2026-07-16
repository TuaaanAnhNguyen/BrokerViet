// lib/widgets/profile/profile_info_section.dart

import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const outline = Color(0xFFC3C6D7);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF7E84A2),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: .5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outline.withValues(alpha: .30)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
