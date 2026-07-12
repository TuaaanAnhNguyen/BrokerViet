// lib/widgets/map/user_location_marker.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserLocationMarker {
  static Marker build(LatLng location) {
    return Marker(
      point: location,
      width: 30,
      height: 30,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
          border: Border.all(color: Colors.white, width: 4),
        ),
      ),
    );
  }
}
