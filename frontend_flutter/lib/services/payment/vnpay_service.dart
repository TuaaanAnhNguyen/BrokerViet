import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VNPayService {
  final _client = Supabase.instance.client;

  /// Step 2: Call create-vnpay-payment edge function
  Future<String?> createPaymentUrl({
    required String bookingId,
    required int amount,
    required String orderInfo,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'create-vnpay-payment',
        method: HttpMethod.post,
        body: {
          'booking_id': bookingId,
          'amount': amount,
          'order_info': orderInfo,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['payment_url'] as String?;
      }
      return null;
    } catch (e) {
      print('Error creating VNPay payment URL: $e');
      return null;
    }
  }

  /// Open VNPay payment URL in browser (not WebView)
  Future<bool> openVNPay(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }

  /// Query payment status from Supabase
  Future<String> getPaymentStatus(String bookingId) async {
    try {
      final response = await _client.functions.invoke(
        'get-payment-status',
        method: HttpMethod.get,
        queryParameters: {
          'booking_id': bookingId,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['status'] as String? ?? 'unknown';
      }
      return 'error';
    } catch (e) {
      print('Error getting payment status: $e');
      return 'error';
    }
  }
}
