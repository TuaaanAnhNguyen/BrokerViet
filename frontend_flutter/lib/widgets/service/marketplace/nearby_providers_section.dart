// lib/widgets/service/marketplace/nearby_providers_section.dart

import 'package:flutter/material.dart';
import '../../../widgets/service/nearby_provider_tile.dart';

class NearbyProvidersSection extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> providers;

  const NearbyProvidersSection({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.providers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn vị cung cấp gần bạn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCCC7)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFA8071A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (providers.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Không tìm thấy đơn vị nào quanh khu vực của bạn.',
            style: TextStyle(color: Colors.black38, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final item = providers[index];
          final double distanceMeters = (item['distance_meters'] as num? ?? 0)
              .toDouble();
          final String distanceStr = distanceMeters >= 1000
              ? 'Cách ${(distanceMeters / 1000).toStringAsFixed(1)} km'
              : 'Cách ${distanceMeters.toStringAsFixed(0)} m';

          return NearbyProviderTile(
            name: item['username'] ?? item['email'] ?? 'Đơn vị ẩn danh',
            distance: distanceStr,
          );
        },
      ),
    );
  }
}
