import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/dashboard_summary_model.dart';
import '../../models/provider_booking_model.dart';
import '../../models/booking_model.dart';

class ProviderDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DashboardSummaryModel> fetchDashboardSummary() async {
    try {
      final response = await _supabase.functions.invoke(
        'get-provider-dashboard-summary',
      );

      final data = response.data;
      print('DASHBOARD RESPONSE: $data');

      if (response.status != 200 ||
          data == null ||
          data is! Map<String, dynamic>) {
        throw Exception(data is Map ? data['error'] : 'Unknown error');
      }

      return DashboardSummaryModel.fromJson(data);
    } catch (e) {
      print('>>> Error fetching dashboard summary: $e');
      return const DashboardSummaryModel(
        todaysBookings: 5,
        pendingRequests: 3,
        revenueToday: '1.250.000 đ',
        monthlyRevenue: '15.400.000 đ',
        averageRating: 4.8,
        totalCompletedJobs: 124,
      );
    }
  }

  Future<UpcomingBookingsPage> fetchUpcomingBookings({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-provider-upcoming-bookings',
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final data = response.data;

      // Edge Function trả về { items: [...], hasMore, nextOffset }
      if (response.status == 200 &&
          data is Map<String, dynamic> &&
          data['items'] is List) {
        final items = (data['items'] as List)
            .map(
              (e) => ProviderBookingModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();

        return UpcomingBookingsPage(
          items: items,
          hasMore: data['hasMore'] as bool? ?? false,
          nextOffset: data['nextOffset'] as int? ?? offset + items.length,
        );
      }
      return const UpcomingBookingsPage(
        items: [],
        hasMore: false,
        nextOffset: 0,
      );
    } catch (e) {
      print('>>> Error fetching upcoming bookings: $e');
      // Mock data chỉ trả ở trang đầu, tránh lặp lại vô hạn khi test load-more
      if (offset > 0) {
        return const UpcomingBookingsPage(
          items: [],
          hasMore: false,
          nextOffset: 0,
        );
      }
      return UpcomingBookingsPage(
        hasMore: false,
        nextOffset: 3,
        items: [
          ProviderBookingModel(
            bookingId: '1',
            customerName: 'Nguyễn Văn A',
            customerAvatar: null,
            serviceTitle: 'Sửa chữa máy lạnh',
            date: DateTime.now().add(const Duration(hours: 2)),
            status: BookingStatus.dangThucHien,
          ),
          ProviderBookingModel(
            bookingId: '2',
            customerName: 'Trần Thị B',
            customerAvatar: null,
            serviceTitle: 'Bảo trì tủ lạnh',
            date: DateTime.now().add(const Duration(days: 1)),
            status: BookingStatus.daHoanThanh,
          ),
          ProviderBookingModel(
            bookingId: '3',
            customerName: 'Lê Văn C',
            customerAvatar: null,
            serviceTitle: 'Lắp đặt điều hòa',
            date: DateTime.now().add(const Duration(days: 2)),
            status: BookingStatus.daHuy,
          ),
        ],
      );
    }
  }
}

class UpcomingBookingsPage {
  final List<ProviderBookingModel> items;
  final bool hasMore;
  final int nextOffset;

  const UpcomingBookingsPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });
}
