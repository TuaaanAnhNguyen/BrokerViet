// lib/features/main/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/map/map_service.dart';

class MapScreen extends StatefulWidget {
  final double? initialTargetLat;
  final double? initialTargetLng;
  final String? initialProviderName;

  const MapScreen({
    super.key,
    this.initialTargetLat,
    this.initialTargetLng,
    this.initialProviderName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();

  LatLng _currentCenter = const LatLng(10.8231, 106.6297);
  LatLng? _userHomeLocation;

  bool _isLoading = false;
  String? _errorMessage;

  List<Polyline> _routeLines = [];
  double? _routeDistanceMeters;
  double? _routeDurationSeconds;

  @override
  void initState() {
    super.initState();
    _initializeMapFocus();
  }

  String get formattedDistance {
    if (_routeDistanceMeters == null) return '';

    if (_routeDistanceMeters! < 1000) {
      return '${_routeDistanceMeters!.round()} m';
    }

    return '${(_routeDistanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _initializeMapFocus() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('location_latitude, location_longitude')
            .eq('user_id', currentUser.id)
            .maybeSingle();

        if (profile != null) {
          final lat = (profile['location_latitude'] as num?)?.toDouble();
          final lng = (profile['location_longitude'] as num?)?.toDouble();

          if (lat != null && lng != null) {
            _userHomeLocation = LatLng(lat, lng);
          }
        }
      }

      if (widget.initialTargetLat != null && widget.initialTargetLng != null) {
        _currentCenter = LatLng(
          widget.initialTargetLat!,
          widget.initialTargetLng!,
        );
      } else if (_userHomeLocation != null) {
        _currentCenter = _userHomeLocation!;
      }

      if (_userHomeLocation != null &&
          widget.initialTargetLat != null &&
          widget.initialTargetLng != null) {
        try {
          print('\n========== LOADING ROUTE ==========');

          final route = await _mapService.getRoute(
            origin: _userHomeLocation!,
            destination: LatLng(
              widget.initialTargetLat!,
              widget.initialTargetLng!,
            ),
          );

          print('Route loaded with ${route.points.length} points.');

          setState(() {
            _routeLines = [
              Polyline(
                points: route.points,
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ];

            _routeDistanceMeters = route.distanceMeters;
            _routeDurationSeconds = route.durationSeconds;
          });
        } catch (e) {
          print('Route loading failed: $e');

          setState(() {
            _errorMessage =
                'Không thể tải tuyến đường. Hiển thị đường thẳng thay thế.';
          });
          setState(() {
            _routeLines = [
              Polyline(
                points: [
                  _userHomeLocation!,
                  LatLng(widget.initialTargetLat!, widget.initialTargetLng!),
                ],
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ];

            _routeDistanceMeters = null;
            _routeDurationSeconds = null;
          });
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_userHomeLocation != null &&
            widget.initialTargetLat != null &&
            widget.initialTargetLng != null) {
          final bounds = LatLngBounds.fromPoints([
            _userHomeLocation!,
            LatLng(widget.initialTargetLat!, widget.initialTargetLng!),
          ]);

          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
          );
        }
      });
    } catch (e) {
      setState(() => _errorMessage = "Không thể tải cấu hình bản đồ.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _recenterToMyPosition() {
    if (_userHomeLocation != null) {
      _mapController.move(_userHomeLocation!, 14.5);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng cập nhật địa chỉ trong hồ sơ trước.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialProviderName != null
              ? 'Vị trí: ${widget.initialProviderName}'
              : 'Bản đồ đối tác',
        ),
        backgroundColor: const Color(0xFF004AC6),
        foregroundColor: Colors.white,
        actions: [
          if (_userHomeLocation != null)
            IconButton(
              icon: const Icon(Icons.my_location_rounded),
              tooltip: 'Vị trí của tôi',
              onPressed: _recenterToMyPosition,
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 14.0,
              maxZoom: 18.0,
              minZoom: 6.0,
              onPositionChanged: (position, hasGesture) {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.broker_viet.app',
              ),
              PolylineLayer(polylines: _routeLines),
              MarkerLayer(
                markers: [
                  // Current user's location
                  if (_userHomeLocation != null)
                    Marker(
                      point: _userHomeLocation!,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                    ),

                  if (widget.initialTargetLat != null &&
                      widget.initialTargetLng != null)
                    Marker(
                      point: LatLng(
                        widget.initialTargetLat!,
                        widget.initialTargetLng!,
                      ),
                      width: 90,
                      height: 90,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.initialProviderName ?? 'Đơn vị dịch vụ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 48,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white60,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF004AC6),
                    ),
                  ),
                ),
              ),
            ),

          if (_errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (_routeDistanceMeters != null && _routeDurationSeconds != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.route, color: Color(0xFF004AC6)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Khoảng cách: $formattedDistance',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Thời gian dự kiến: ${(_routeDurationSeconds! / 60).round()} phút',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
