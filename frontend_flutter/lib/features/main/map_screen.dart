// lib/features/main/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/provider_service_info_model.dart';
import '../../models/route_result_model.dart';
import '../../services/map-location/location_service.dart';

import '../../widgets/map/map_content_view.dart';
import '../../widgets/map/map_floating_overlay.dart';
import '../../widgets/map/my_location_button.dart';

class MapScreen extends StatefulWidget {
  final String serviceId;
  final double initialTargetLat;
  final double initialTargetLng;
  final String initialProviderName;

  const MapScreen({
    super.key,
    required this.serviceId,
    required this.initialTargetLat,
    required this.initialTargetLng,
    required this.initialProviderName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  late final LatLng _destination;
  RouteResult? _route;
  ProviderServiceInfo? _providerInfo;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _destination = LatLng(widget.initialTargetLat, widget.initialTargetLng);
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final myLocation = await _locationService.getMyLocation();
      _userLocation = LatLng(myLocation.latitude, myLocation.longitude);

      _providerInfo = await _locationService.getProviderServiceInfo(
        serviceId: widget.serviceId,
      );

      _route = await _locationService.getRoute(
        origin: _userLocation!,
        destination: _destination,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([_userLocation!, _destination]),
            padding: const EdgeInsets.all(60),
          ),
        );
      });
    } on LocationServiceException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _recenter() {
    if (_userLocation == null) return;
    _mapController.move(_userLocation!, 14.5);
  }

  @override
  Widget build(BuildContext context) {
    final providerName =
        _providerInfo?.providerName ?? widget.initialProviderName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _providerInfo != null
              ? _providerInfo!.title
              : widget.initialProviderName,
        ),
        backgroundColor: const Color(0xFF004AC6),
        foregroundColor: Colors.white,
        actions: [
          if (_userLocation != null) MyLocationButton(onPressed: _recenter),
        ],
      ),
      body: Stack(
        children: [
          MapContentView(
            mapController: _mapController,
            destination: _destination,
            userLocation: _userLocation,
            route: _route,
            providerName: providerName,
          ),

          MapFloatingOverlay(
            loading: _loading,
            error: _error,
            route: _route,
            providerInfo: _providerInfo,
          ),
        ],
      ),
    );
  }
}
