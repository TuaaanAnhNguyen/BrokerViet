// lib/widgets/service/service_tags_section.dart

import 'package:flutter/material.dart';

class ServiceTagsSection extends StatelessWidget {
  final String? categoryName;

  const ServiceTagsSection({super.key, this.categoryName});

  @override
  Widget build(BuildContext context) {
    if (categoryName == null) return const SizedBox.shrink();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF39B8FD).withAlpha(38),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            categoryName!,
            style: const TextStyle(
              color: Color(0xFF006591),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}