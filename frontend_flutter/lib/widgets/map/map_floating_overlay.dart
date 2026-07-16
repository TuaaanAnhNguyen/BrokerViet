// lib/widgets/map/map_floating_overlay.dart

import 'package:flutter/material.dart';
import '../../models/provider_service_info_model.dart';
import '../../models/route_result_model.dart';
import 'error_banner.dart';
import 'loading_overlay.dart';
import 'provider_service_info_card.dart';
import 'route_info_card.dart';

class MapFloatingOverlay extends StatelessWidget {
  final bool loading;
  final String? error;
  final RouteResult? route;
  final ProviderServiceInfo? providerInfo;

  const MapFloatingOverlay({
    super.key,
    required this.loading,
    required this.error,
    required this.route,
    required this.providerInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (loading) const LoadingOverlay(),
        if (error != null) ErrorBanner(message: error!),

        if (route != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: providerInfo == null ? 20 : 190,
            child: RouteInfoCard(
              distanceMeters: route!.distanceMeters,
              durationSeconds: route!.durationSeconds,
            ),
          ),

        if (providerInfo != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: ProviderServiceInfoCard(service: providerInfo!),
          ),
      ],
    );
  }
}
