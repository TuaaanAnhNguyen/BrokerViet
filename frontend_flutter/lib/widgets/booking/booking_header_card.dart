// lib/widgets/booking/booking_header_card.dart

import 'package:flutter/material.dart';

class BookingHeaderCard extends StatelessWidget {
  final String serviceTitle;
  final String packageName;
  final String? serviceImageUrl;

  const BookingHeaderCard({
    super.key,
    required this.serviceTitle,
    required this.packageName,
    this.serviceImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFE5EEFF),
              image: serviceImageUrl != null && serviceImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(serviceImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: serviceImageUrl == null || serviceImageUrl!.isEmpty
                ? const Icon(
                    Icons.build_circle_outlined,
                    color: primaryColor,
                    size: 36,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHI TIẾT ĐƠN ĐẶT DỊCH VỤ',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  serviceTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Gói: $packageName',
                  style: const TextStyle(
                    color: bodyText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}