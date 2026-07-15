// lib/widgets/service/service_detail/service_provider_card.dart

import 'package:flutter/material.dart';
import '../../../widgets/avatar_builder.dart';
import '../../../screens/provider/view_provider_screen.dart';

class ServiceProviderCard extends StatelessWidget {
  final String? providerId;
  final String? providerUsername;
  final String? providerAvatarUrl;
  final Color darkText;
  final Color bodyText;
  final Color primaryColor;

  const ServiceProviderCard({
    super.key,
    required this.providerId,
    required this.providerUsername,
    required this.providerAvatarUrl,
    required this.darkText,
    required this.bodyText,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String name = providerUsername ?? 'Nhà cung cấp';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewProviderScreen(
              providerId: providerId ?? '',
              providerName: name,
              avatarUrl: providerAvatarUrl,
              isPro: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EEFF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC3C6D7).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            buildAvatar(providerAvatarUrl ?? '', radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: bodyText),
                      const SizedBox(width: 4),
                      Text(
                        'Phản hồi ~15 phút',
                        style: TextStyle(color: bodyText, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
