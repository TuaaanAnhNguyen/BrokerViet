// frontend_flutter/lib/services/map-location/location_service.dart
// formerly map_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:broker_viet/models/route_result_model.dart';
import '../../models/provider_service_info_model.dart';
import '../../models/provider_location_model.dart';
import '../../models/geocoding_result.dart';
import '../../models/reverse_geocoding_result.dart';

class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

class LocationService {
  final SupabaseClient _supabaseClient;

  LocationService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> findNearbyProviders({
    required double latitude,
    required double longitude,
    double radiusMeters = 10000,
    int limit = 15,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'find-nearby-providers',
        method: HttpMethod.post,
        body: {
          'lat': latitude,
          'lng': longitude,
          'radiusMeters': radiusMeters,
          'limit': limit,
        },
      );

      print('====================\n');
      print('Status: ${response.status}');
      print('Raw response: ${response.data}');
      print('====================\n');

      if (response.status != 200) {
        throw LocationServiceException(
          'Failed to fetch nearby providers. Status: ${response.status}',
        );
      }

      if (response.data == null) {
        throw LocationServiceException(
          'Edge Function returned a null response.',
        );
      }

      final responseData = Map<String, dynamic>.from(response.data as Map);

      print('Decoded response: $responseData');

      if (responseData['success'] != true) {
        throw LocationServiceException(
          responseData['error']?.toString() ??
              'Unknown error returned from Edge Function.',
        );
      }

      final providersRaw = responseData['providers'];

      if (providersRaw == null) {
        return [];
      }

      final providers = (providersRaw as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      print('Nearby providers found: ${providers.length}');

      for (final provider in providers) {
        print(provider);
      }

      return providers;
    } on FunctionException catch (e) {
      throw LocationServiceException(
        'Edge Function error: ${e.details ?? e.toString()} (Status: ${e.status})',
      );
    } on PostgrestException catch (e) {
      throw LocationServiceException('Database error: ${e.message}');
    } catch (e, stack) {
      print(stack);

      throw LocationServiceException('Unexpected error: $e');
    }
  }

  Future<GeocodingResult> geocodeAddress({required String address}) async {
    try {
      print('\n========== GEOCODE ADDRESS ==========');
      print('Input: $address');

      final response = await _supabaseClient.functions.invoke(
        'geocode-address',
        method: HttpMethod.post,
        body: {'address': address},
      );

      print('Status: ${response.status}');

      print("===== RESPONSE TYPE =====");
      print(response.data.runtimeType);
      print(response.data);

      if (response.status != 200) {
        throw LocationServiceException('Unable to geocode address.');
      }

      final json = Map<String, dynamic>.from(response.data);

      if (json['success'] != true) {
        throw LocationServiceException(
          json['error'] ?? 'Unknown geocoding error.',
        );
      }

      print(json);

      print(json['formattedAddress']);
      print(json['formattedAddress'].runtimeType);

      return GeocodingResult(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        displayName: json['formattedAddress'].toString(),
      );
    } on FunctionException catch (e) {
      final details = e.details;

      if (details is Map) {
        throw LocationServiceException(
          details['error']?.toString() ?? details.toString(),
        );
      }

      throw LocationServiceException(details?.toString() ?? e.toString());
    } catch (e, stack) {
      print("========== GEOCODE ERROR ==========");
      print(e);
      print(stack);
      throw LocationServiceException(e.toString());
    }
  }

  Future<ReverseGeocodingResult> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('\n========== REVERSE GEOCODE ==========');
      print('Latitude : $latitude');
      print('Longitude: $longitude');

      final response = await _supabaseClient.functions.invoke(
        'reverse-geocode',
        method: HttpMethod.post,
        body: {'latitude': latitude, 'longitude': longitude},
      );

      print('Status: ${response.status}');
      print('Response: ${response.data}');

      if (response.status != 200) {
        throw LocationServiceException(
          'Unable to reverse geocode coordinates.',
        );
      }

      final json = Map<String, dynamic>.from(response.data);

      if (json['success'] != true) {
        throw LocationServiceException(
          json['error'] ?? 'Unknown reverse geocoding error.',
        );
      }

      return ReverseGeocodingResult.fromJson(json);
    } on FunctionException catch (e) {
      throw LocationServiceException(e.details ?? e.toString());
    } catch (e) {
      throw LocationServiceException(e.toString());
    }
  }

  Future<void> updateProfileLocation({
    required String address,
    required String locationText,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'update-profile-location',
        method: HttpMethod.post,
        body: {
          'address': address,
          'locationText': locationText,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.status != 200) {
        throw LocationServiceException('Unable to update profile location.');
      }

      final json = Map<String, dynamic>.from(response.data);

      if (json['success'] != true) {
        throw LocationServiceException(json['error'] ?? 'Unknown error.');
      }
    } on FunctionException catch (e) {
      throw LocationServiceException(e.details ?? e.toString());
    } catch (e) {
      throw LocationServiceException(e.toString());
    }
  }

  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      print('\n========== GET ROUTE ==========');
      print('Origin: (${origin.latitude}, ${origin.longitude})');
      print('Destination: (${destination.latitude}, ${destination.longitude})');

      final response = await _supabaseClient.functions.invoke(
        'get-route',
        method: HttpMethod.post,
        body: {
          'originLat': origin.latitude,
          'originLng': origin.longitude,
          'destinationLat': destination.latitude,
          'destinationLng': destination.longitude,
        },
      );

      print('Status: ${response.status}');
      print('Raw response: ${response.data}');
      print('===============================\n');

      if (response.status != 200) {
        throw LocationServiceException(
          'Failed to retrieve route. Status: ${response.status}',
        );
      }

      if (response.data == null) {
        throw LocationServiceException('Edge Function returned null.');
      }

      final responseData = Map<String, dynamic>.from(response.data as Map);

      if (responseData['success'] != true) {
        throw LocationServiceException(
          responseData['error']?.toString() ?? 'Unknown routing error.',
        );
      }

      final coordinates = List<Map<String, dynamic>>.from(
        responseData['coordinates'],
      );

      final points = coordinates.map((coordinate) {
        return LatLng(
          (coordinate['lat'] as num).toDouble(),
          (coordinate['lng'] as num).toDouble(),
        );
      }).toList();

      final distanceMeters = (responseData['distanceMeters'] as num).toDouble();

      final durationSeconds = (responseData['durationSeconds'] as num)
          .toDouble();

      print('Route successfully loaded.');
      print('Points: ${points.length}');
      print('Distance: ${(distanceMeters / 1000).toStringAsFixed(2)} km');
      print('Duration: ${(durationSeconds / 60).toStringAsFixed(1)} mins');

      return RouteResult(
        points: points,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
      );
    } on FunctionException catch (e) {
      throw LocationServiceException(
        'Edge Function error: ${e.details ?? e.toString()} '
        '(Status: ${e.status})',
      );
    } on PostgrestException catch (e) {
      throw LocationServiceException('Database error: ${e.message}');
    } catch (e, stack) {
      print(stack);

      throw LocationServiceException('Unexpected routing error: $e');
    }
  }

  Future<ProviderLocation> getMyLocation() async {
    try {
      print('\n========== GET MY LOCATION ==========');

      final response = await _supabaseClient.functions.invoke(
        'get-my-location',
      );

      print('Status: ${response.status}');
      print('Response: ${response.data}');

      if (response.status != 200) {
        throw LocationServiceException('Unable to load current location.');
      }

      final json = Map<String, dynamic>.from(response.data);

      if (json['success'] != true) {
        throw LocationServiceException(json['error'] ?? 'Unknown error.');
      }

      final location = Map<String, dynamic>.from(json['location']);

      return ProviderLocation(
        userId: '',
        username: '',
        latitude: (location['latitude'] as num).toDouble(),
        longitude: (location['longitude'] as num).toDouble(),
        distanceMeters: 0,
        address: location['address'],
      );
    } on FunctionException catch (e) {
      throw LocationServiceException(e.details ?? e.toString());
    } catch (e) {
      throw LocationServiceException(e.toString());
    }
  }

  Future<ProviderServiceInfo> getProviderServiceInfo({
    required String serviceId,
  }) async {
    try {
      print('\n========== GET PROVIDER SERVICE ==========');

      final response = await _supabaseClient.functions.invoke(
        'get-provider-service-info-on-map',
        body: {'serviceId': serviceId},
      );

      print('Status: ${response.status}');
      print('Response: ${response.data}');

      if (response.status != 200) {
        throw LocationServiceException('Unable to load provider service.');
      }

      final json = Map<String, dynamic>.from(response.data);

      if (json['success'] != true) {
        throw LocationServiceException(json['error'] ?? 'Unknown error.');
      }

      return ProviderServiceInfo.fromJson(
        Map<String, dynamic>.from(json['service']),
      );
    } on FunctionException catch (e) {
      throw LocationServiceException(e.details ?? e.toString());
    } catch (e) {
      throw LocationServiceException(e.toString());
    }
  }

  Future<ProviderLocation> getProviderLocation({
    required String providerId,
  }) async {
    try {
      print('\n========== GET PROVIDER LOCATION ==========');

      final response = await _supabaseClient.functions.invoke(
        'get-provider-location',
        method: HttpMethod.post,
        body: {'providerId': providerId},
      );

      print('Status: ${response.status}');
      print('Response: ${response.data}');

      if (response.status != 200) {
        throw LocationServiceException('Unable to load provider location.');
      }

      final json = Map<String, dynamic>.from(response.data);

      if (json['success'] != true) {
        throw LocationServiceException(json['error'] ?? 'Unknown error.');
      }

      final location = Map<String, dynamic>.from(json['location']);

      return ProviderLocation(
        userId: providerId,
        username: '',
        latitude: (location['latitude'] as num).toDouble(),
        longitude: (location['longitude'] as num).toDouble(),
        distanceMeters: 0,
        address: location['address'],
      );
    } on FunctionException catch (e) {
      throw LocationServiceException(e.details ?? e.toString());
    } catch (e) {
      throw LocationServiceException(e.toString());
    }
  }
}
