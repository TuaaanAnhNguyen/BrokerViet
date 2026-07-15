// lib/models/provider_location_model.dart

class ProviderLocation {
  final String userId;
  final String username;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String? address;

  ProviderLocation({
    required this.userId,
    required this.username,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.address,
  });
}
