// lib/widgets/service/service_description_section.dart

import 'package:flutter/material.dart';

class ServiceDescriptionSection extends StatelessWidget {
  final String description;

  const ServiceDescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Về dịch vụ này',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: bodyText, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }
}
