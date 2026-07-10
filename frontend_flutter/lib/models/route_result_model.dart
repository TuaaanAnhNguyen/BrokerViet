// lib/models/route_result_model.dart

import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;

  final double distanceMeters;

  final double durationSeconds;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}