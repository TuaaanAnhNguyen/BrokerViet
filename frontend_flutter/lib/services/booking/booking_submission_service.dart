/*
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingSubmissionService {
  final _supabase = Supabase.instance.client;

  Future<bool> submitBooking({
    required String serviceId,
    required String serviceTitle,
    required String providerName,
    required String packageName,
    required String price,
    required String scheduledDate,
    required String scheduledTime,
    required String address,
    required String notes,
    required String paymentMethod,
  }) async {
    try {
      final payload = {
        'service_id': serviceId,
        'service_title': serviceTitle,
        'provider_name': providerName,
        'package_name': packageName,
        'price': price,
        'scheduled_date': scheduledDate,
        'scheduled_time': scheduledTime,
        'address': address,
        'notes': notes,
        'payment_method': paymentMethod,
        'requested_at': DateTime.now().toIso8601String(),
        'user_id': _supabase.auth.currentUser?.id,
      };

      final response = await _supabase.functions.invoke(
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

      return response.status == 200 || response.status == 201;
    } on FunctionException catch (e) {
      debugPrint('BookingSubmissionService: function exception: ${e.details}');
      return false;
    } catch (e) {
      debugPrint('BookingSubmissionService: unknown error: $e');
      return false;
    }
  }
}
*/
