// lib/widgets/map/route_info_card.dart

import 'package:flutter/material.dart';

class RouteInfoCard extends StatelessWidget {
  final double distanceMeters;
  final double durationSeconds;

  const RouteInfoCard({
    super.key,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }

    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.route, color: Color(0xFF004AC6)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khoảng cách: $formattedDistance',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thời gian dự kiến: ${(durationSeconds / 60).round()} phút',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
