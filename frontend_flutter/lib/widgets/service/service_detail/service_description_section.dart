import 'package:flutter/material.dart';

class ServiceDescriptionSection extends StatelessWidget {
  final String subtitle;
  final Color darkText;
  final Color bodyText;

  const ServiceDescriptionSection({
    super.key,
    required this.subtitle,
    required this.darkText,
    required this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Về dịch vụ này',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: bodyText, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }
}
