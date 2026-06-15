import 'package:broker_viet/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final _client = Supabase.instance.client;



  // ── CREATE ────────────────────────────────────────────────
  Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required String customerId,
    required String providerId,
    required int totalPrice,
    required DateTime scheduledAt,
    String? serviceType,

  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    print('Session exists: ${session != null}');
    print('User id: ${session?.user.id}');
    print('Token exists: ${session?.accessToken.isNotEmpty}');
    final response = await _client.functions.invoke(
      'create-booking',
      method: HttpMethod.post,
      body: {
        'service_id':   serviceId,
        'customer_id':  customerId,
        'provider_id':  providerId,
        'total_price':  totalPrice,
        'scheduled_at': scheduledAt.toIso8601String(),
        if (serviceType != null) 'service_type': serviceType,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  // ── GET ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> getBooking(String bookingId) async {
    final response = await _client.functions.invoke(
      'get-booking',
      method: HttpMethod.get,
      queryParameters: {'booking_id': bookingId},
    );

    return response.data as Map<String, dynamic>;
  }

  // ── LIST ──────────────────────────────────────────────────
  Future<List<BookingModel>> listBookings({
    String? customerId,
    String? providerId,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.functions.invoke(
      'list-bookings',
      method: HttpMethod.get,
      queryParameters: {
        if (customerId != null) 'customer_id': customerId,
        if (providerId != null) 'provider_id': providerId,
        if (status != null)     'status':      status,
        'limit':  limit.toString(),
        'offset': offset.toString(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['bookings'] as List<BookingModel>;
  }

  // ── UPDATE ────────────────────────────────────────────────
  Future<bool> updateBooking(
      String bookingId, {
        String? status,
        DateTime? scheduledAt,
        DateTime? completedAt,
        int? totalPrice,
        String? serviceType,
      }) async {
    await _client.functions.invoke(
      'update-booking',
      method: HttpMethod.patch,
      queryParameters: {'booking_id': bookingId},
      body: {
        if (status != null) 'status': status,
        if (scheduledAt != null)
          'scheduled_at': scheduledAt.toIso8601String(),
        if (completedAt != null)
          'completed_at': completedAt.toIso8601String(),
        if (totalPrice != null) 'total_price': totalPrice,
        if (serviceType != null) 'service_type': serviceType,
      },
    );

    return true;
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<void> deleteBooking(String bookingId) async {
    await _client.functions.invoke(
      'delete-booking',
      method: HttpMethod.delete,
      queryParameters: {'booking_id': bookingId},
    );
  }
}