import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/provider_booking_model.dart';
import '../../models/booking_model.dart';

class ProviderBookingsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProviderBookingModel>> fetchBookings({
    String filter = 'All',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-provider-bookings',
        body: {
          'status_filter': filter,
          'page_number': page,
          'page_size': pageSize,
        },
      );

      final data = response.data;
      // Edge Function trả về object { items, total_count, page, page_size }
      // chứ không phải array thẳng như khi gọi RPC trực tiếp
      if (data is Map<String, dynamic> && data['items'] is List) {
        final items = data['items'] as List;
        return items
            .map(
              (e) => ProviderBookingModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('>>> Error fetching bookings: $e');
      // Mock data to test UI
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network
      return _getMockBookings(filter);
    }
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'update-booking-status',
        body: {'booking_id': bookingId, 'new_status': newStatus.toDbString()},
      );

      if (response.status != 200) {
        final errorMsg = response.data is Map
            ? (response.data['error'] ?? 'Unknown error')
            : 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('>>> Error updating booking status: $e');
      throw Exception('Failed to update backend database status: $e');
    }
  }

  List<ProviderBookingModel> _getMockBookings(String filter) {
    final now = DateTime.now();
    final List<ProviderBookingModel> allMocks = [
      ProviderBookingModel(
        bookingId: '1',
        customerName: 'Nguyễn Văn A',
        customerAvatar: null,
        serviceTitle: 'Sửa chữa máy lạnh',
        date: now.add(const Duration(hours: 2)),
        status: BookingStatus.dangChoDuyet,
        price: 350000,
        address: '123 Nguyễn Thị Minh Khai, Quận 1, TP.HCM',
        customerNotes: 'Máy lạnh không lạnh, kêu to',
        requestedAt: now.subtract(const Duration(days: 1)),
      ),
      ProviderBookingModel(
        bookingId: '4',
        customerName: 'Phạm Văn D',
        customerAvatar: null,
        serviceTitle: 'Sửa tivi',
        date: now.subtract(const Duration(days: 1)),
        status: BookingStatus.daHoanThanh,
        price: 250000,
        address: '12 Phạm Ngọc Thạch, Quận 3, TP.HCM',
        requestedAt: now.subtract(const Duration(days: 4)),
        confirmedAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      ProviderBookingModel(
        bookingId: '5',
        customerName: 'Hoàng Thị E',
        customerAvatar: null,
        serviceTitle: 'Vệ sinh máy giặt',
        date: now.subtract(const Duration(days: 2)),
        status: BookingStatus.daHuy,
        price: 200000,
        address: '77 Trần Hưng Đạo, Quận 5, TP.HCM',
        requestedAt: now.subtract(const Duration(days: 5)),
      ),
      ProviderBookingModel(
        bookingId: '6',
        customerName: 'Ngô Văn F',
        customerAvatar: null,
        serviceTitle: 'Sửa lò vi sóng',
        date: now.add(const Duration(hours: 5)),
        status: BookingStatus.dangChoDuyet,
        price: 100000,
        address: '99 Điện Biên Phủ, Bình Thạnh, TP.HCM',
        requestedAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    if (filter == 'All') return allMocks;

    return allMocks.where((b) {
      if (filter == 'Pending') return b.status == BookingStatus.dangChoDuyet;
      if (filter == 'Completed') return b.status == BookingStatus.daHoanThanh;
      if (filter == 'Cancelled') return b.status == BookingStatus.daHuy;
      return true;
    }).toList();
  }
}
