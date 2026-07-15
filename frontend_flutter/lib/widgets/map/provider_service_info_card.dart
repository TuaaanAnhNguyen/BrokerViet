// lib/widgets/map/provider_service_info_card.dart

// lib/widgets/map/provider_service_info_card.dart

import 'package:flutter/material.dart';

import '../../models/provider_service_info_model.dart';
import '../network_image_fallback.dart';

class ProviderServiceInfoCard extends StatelessWidget {
  final ProviderServiceInfo service;

  const ProviderServiceInfoCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: NetworkImageWithFallback(
                imageUrl: service.imageUrl?.trim().isNotEmpty == true
                    ? service.imageUrl!
                    : 'assets/no_icon_placeholder.png',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    service.providerName,
                    style: const TextStyle(
                      color: Color(0xFF004AC6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (service.categoryName != null &&
                      service.categoryName!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.categoryName!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(service.rating.toStringAsFixed(1)),

                      const Spacer(),

                      Text(
                        '${service.price.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                          color: Color(0xFF004AC6),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  if (service.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
