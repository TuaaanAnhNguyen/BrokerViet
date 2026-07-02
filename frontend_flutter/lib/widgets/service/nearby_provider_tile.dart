// lib/widgets/service/nearby_provider_tile.dart

import 'package:flutter/material.dart';

class NearbyProviderTile extends StatelessWidget {
  final String name;
  final String distance;
  final String? score;

  const NearbyProviderTile({
    super.key,
    required this.name,
    required this.distance,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE5EEFF),
            child: Icon(
              Icons.person,
              color: const Color(0xFF004AC6).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            distance,
            style: const TextStyle(color: Color(0xFF434655), fontSize: 11),
          ),
          if (score != null && score!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 2),
                Text(
                  score!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006591),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
