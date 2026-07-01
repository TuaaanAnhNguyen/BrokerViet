// lib/features/main/map_screen.dart

import 'dart:math';
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

  List<Map<String, dynamic>> _nearbyProviders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Polyline> _routeLines = [];

  @override
  void initState() {
    super.initState();
    _initializeMapFocus();
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

      await _fetchSurroundingProviders(_currentCenter);

      if (_userHomeLocation != null &&
          widget.initialTargetLat != null &&
          widget.initialTargetLng != null) {
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

  Future<void> _fetchSurroundingProviders(LatLng centerPoint) async {
    try {
      final providers = await _mapService.findNearbyProviders(
        latitude: centerPoint.latitude,
        longitude: centerPoint.longitude,
        radiusMeters: 20000, // 20km
        limit: 30,
      );
      setState(() {
        _nearbyProviders = providers;
        _errorMessage = null;
      });
    } catch (e) {
      setState(
        () => _errorMessage = "Không thể tải danh sách đơn vị xung quanh.",
      );
    }
  }

  void _recenterToMyPosition() {
    if (_userHomeLocation != null) {
      _mapController.move(_userHomeLocation!, 14.5);
      _fetchSurroundingProviders(_userHomeLocation!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng cập nhật địa chỉ ở trang Marketplace trước.'),
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
              onPositionChanged: (position, hasGesture) {
              },
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

                  // Red Markers: Map dynamically queried backend providers coordinates
                  ..._nearbyProviders.map((prov) {
                    final double lat = (prov['latitude'] as num).toDouble();
                    final double lng = (prov['longitude'] as num).toDouble();

                    final bool isSelected =
                        widget.initialTargetLat != null &&
                        widget.initialTargetLng != null &&
                        (lat - widget.initialTargetLat!).abs() < 0.00001 &&
                        (lng - widget.initialTargetLng!).abs() < 0.00001;

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 90,
                      height: 90,
                      child: GestureDetector(
                        onTap: () => _showProviderDetailsModal(prov),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
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
                                  prov['username'] ?? 'Đối tác',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),

                            Icon(
                              Icons.location_on,
                              size: isSelected ? 48 : 38,
                              color: isSelected
                                  ? Colors.red
                                  : Colors.deepOrange,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Loading Overlay State View
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

          // Error Alerts Toast Notification Box inside maps canvas view bounds
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
        ],
      ),
    );
  }

  void _showProviderDetailsModal(Map<String, dynamic> provider) {
    final double distanceMeters = (provider['distance_meters'] as num? ?? 0)
        .toDouble();
    final String distanceStr = distanceMeters >= 1000
        ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
        : '${distanceMeters.toStringAsFixed(0)} m';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE5EEFF),
                    radius: 24,
                    child: const Icon(
                      Icons.store_rounded,
                      color: Color(0xFF004AC6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider['username'] ?? 'Đơn vị dịch vụ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Khoảng cách: $distanceStr',
                          style: const TextStyle(
                            color: Color(0xFF006591),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Địa chỉ chi tiết:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider['address'] ??
                    provider['location_text'] ??
                    'Chưa xác định cấu hình địa chỉ.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
