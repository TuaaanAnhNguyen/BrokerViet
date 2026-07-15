import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchProviderProfileDetails(
    String providerId,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-provider-profile-details',
        body: {'provider_id': providerId},
      );

      if (response.status != 200) {
        throw Exception(response.data?['error'] ?? 'Lỗi không xác định');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('>>> Lỗi khi fetch provider profile details: $e');
      rethrow;
    }
  }
}
