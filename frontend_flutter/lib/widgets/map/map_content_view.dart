// lib/widgets/map/map_content_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/route_result_model.dart';
import 'destination_marker.dart';
import 'map_tile_layer.dart';
import 'route_polyline_layer.dart';
import 'user_location_marker.dart';

class MapContentView extends StatelessWidget {
  final MapController mapController;
  final LatLng destination;
  final LatLng? userLocation;
  final RouteResult? route;
  final String providerName;

  const MapContentView({
    super.key,
    required this.mapController,
    required this.destination,
    required this.userLocation,
    required this.route,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: destination,
        initialZoom: 14,
        minZoom: 6,
        maxZoom: 18,
      ),
      children: [
        const MapTileLayer(),
        if (route != null)
          PolylineLayer(polylines: RoutePolylineBuilder.build(route!.points)),
        MarkerLayer(
          markers: [
            if (userLocation != null) UserLocationMarker.build(userLocation!),
            DestinationMarker.build(
              location: destination,
              providerName: providerName,
            ),
          ],
        ),
      ],
    );
  }
}
