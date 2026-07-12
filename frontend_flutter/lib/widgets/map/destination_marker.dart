// lib/widgets/map/destination_marker.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DestinationMarker {
  static Marker build({
    required LatLng location,
    required String providerName,
  }) {
    return Marker(
      point: location,
      width: 90,
      height: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              providerName,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          const Icon(Icons.location_on, color: Colors.red, size: 48),
        ],
      ),
    );
  }
}
