// lib/widgets/map/route_polyline_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RoutePolylineBuilder {
  static List<Polyline> build(List<LatLng> points) {
    return [Polyline(points: points, strokeWidth: 5, color: Colors.blue)];
  }
}
