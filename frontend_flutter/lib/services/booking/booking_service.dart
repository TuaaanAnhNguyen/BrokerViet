import 'package:broker_viet/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../notification/notification_service.dart';

class BookingService {
  final _client = Supabase.instance.client;
  final _notificationService = NotificationService();

  // ── CREATE ────────────────────────────────────────────────
  Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required String customerId,
    required String providerId,
    required int totalPrice,
    required DateTime scheduledAt,
    String? serviceType,
  }) async {
    final response = await _client.functions.invoke(
      'create-booking',
      method: HttpMethod.post,
      body: {
        'service_id': serviceId,
        'customer_id': customerId,
        'provider_id': providerId,
        'total_price': totalPrice,
        'scheduled_at': scheduledAt.toIso8601String(),
        if (serviceType != null) 'service_type': serviceType,
      },
    );

    // After successful creation, notify both parties
    try {
      final customerProfile = await _client
          .from('profiles')
          .select('username')
          .eq('user_id', customerId)
          .maybeSingle();
      final customerName = customerProfile?['username'] ?? 'Khách hàng';
      final sType = serviceType ?? 'Dịch vụ';

      // Notify Provider
      print("notifying provider");
      await _notificationService.createNotification(
        userId: providerId,
        title: 'Yêu cầu đặt lịch mới',
        content: '$customerName vừa đặt lịch dịch vụ "$sType" của bạn.',
      );

      // Notify Customer
      print("Notifying customers");
      await _notificationService.createNotification(
        userId: customerId,
        title: 'Đặt lịch thành công',
        content: 'Yêu cầu cho dịch vụ "$sType" đã được gửi thành công và đang chờ xác nhận.',
      );
    } catch (e) {
      print('Error creating booking notification: $e');
    }

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
    try {
      final response = await _client.functions.invoke(
        'list-booking',
        method: HttpMethod.get,
        queryParameters: {
          if (customerId != null) 'customer_id': customerId,
          if (providerId != null) 'provider_id': providerId,
          if (status != null) 'status': status,
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> bookingsJson = data['bookings'] ?? [];

      return bookingsJson.map((json) {
        return BookingModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('BookingService Error: $e');
      rethrow;
    }
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
    // 1. Get booking details to know who to notify
    final bookingData = await _client
        .from('bookings')
        .select('customer_id, provider_id, service_type')
        .eq('booking_id', bookingId)
        .maybeSingle();

    await _client.functions.invoke(
      'update-booking',
      method: HttpMethod.patch,
      queryParameters: {'booking_id': bookingId},
      body: {
        if (status != null) 'status': status,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
        if (completedAt != null) 'completed_at': completedAt.toIso8601String(),
        if (totalPrice != null) 'total_price': totalPrice,
        if (serviceType != null) 'service_type': serviceType,
      },
    );

    // 2. Send notification if status changed
    print("checking status for notification preparing");
    if (status != null && bookingData != null) {
      final customerId = bookingData['customer_id'];
      final providerId = bookingData['provider_id'];
      final sType = bookingData['service_type'] ?? 'Dịch vụ';
      
      final currentUserId = _client.auth.currentUser?.id;
      final recipientId = (currentUserId == customerId) ? providerId : customerId;
      
      String title = 'Cập nhật đơn hàng';
      String content = 'Đơn hàng #$bookingId đã chuyển sang trạng thái $status';

      final statusLower = status.toLowerCase();

      if (statusLower.contains('duyệt') || statusLower.contains('chấp nhận') || statusLower == 'pending') {
        title = 'Đơn hàng đã được duyệt';
        content = 'Yêu cầu cho dịch vụ "$sType" của bạn đã được chấp nhận.';
      } else if (statusLower.contains('hủy') || statusLower == 'cancelled') {
        title = 'Đơn hàng đã bị hủy';
        content = 'Đơn hàng cho dịch vụ "$sType" đã được hủy thành công.';
      } else if (statusLower.contains('hoàn thành') || statusLower == 'completed') {
        title = 'Dịch vụ hoàn tất';
        content = 'Dịch vụ "$sType" đã được đánh dấu là hoàn thành.';
      } else if (statusLower.contains('từ chối') || statusLower == 'rejected') {
        title = 'Đơn hàng bị từ chối';
        content = 'Yêu cầu cho dịch vụ "$sType" của bạn đã bị đối tác từ chối.';
      }

      await _notificationService.createNotification(
        userId: recipientId,
        title: title,
        content: content,
      );
    }

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

  // ── FETCH LATEST ID ───────────────────────────────────────
  Future<String?> getLatestBookingId(String customerId) async {
    try {
      print("fetching booking id");
      final response = await _client
          .from('bookings')
          .select('booking_id')
          .eq('customer_id', customerId)
          .order('booked_at', ascending: false)
          .limit(1)
          .maybeSingle();
      print(response.toString());
      return response?['booking_id']?.toString();
    } catch (e) {
      print('Error fetching latest booking ID: $e');
      return null;
    }
  }
}
