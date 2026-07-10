// frontend_flutter/lib/services/map/map_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class MapServiceException implements Exception {
  final String message;

  MapServiceException(this.message);

  @override
  String toString() => 'MapServiceException: $message';
}

class MapService {
  final SupabaseClient _supabaseClient;

  MapService({SupabaseClient? supabaseClient})
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
        throw MapServiceException(
          'Failed to fetch nearby providers. Status: ${response.status}',
        );
      }

      if (response.data == null) {
        throw MapServiceException(
          'Edge Function returned a null response.',
        );
      }

      final responseData = Map<String, dynamic>.from(
        response.data as Map,
      );

      print('Decoded response: $responseData');

      if (responseData['success'] != true) {
        throw MapServiceException(
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
      throw MapServiceException(
        'Edge Function error: ${e.details ?? e.toString()} (Status: ${e.status})',
      );
    } on PostgrestException catch (e) {
      throw MapServiceException(
        'Database error: ${e.message}',
      );
    } catch (e, stack) {
      print(stack);

      throw MapServiceException(
        'Unexpected error: $e',
      );
    }
  }

  Future<void> updateProviderLocation({
    required String profileId,
    required String address,
    required String locationText,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _supabaseClient.rpc(
        'update_provider_location',
        params: {
          'profile_id': profileId,
          'new_address': address,
          'new_location_text': locationText,
          'new_lat': latitude,
          'new_lng': longitude,
        },
      );
    } on PostgrestException catch (e) {
      throw MapServiceException(
        'Database error updating location: ${e.message}',
      );
    } catch (e) {
      throw MapServiceException(
        'Failed to update coordinates: $e',
      );
    }
  }
}