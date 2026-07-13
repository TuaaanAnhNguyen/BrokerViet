import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/dashboard_summary_model.dart';
import '../../models/provider_booking_model.dart';
import '../../models/booking_model.dart';

class ProviderDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DashboardSummaryModel> fetchDashboardSummary() async {
    try {
      final response = await _supabase.rpc('get_provider_dashboard_summary');

      if (response != null) {
        print('DASHBOARD RESPONSE: $response');
        return DashboardSummaryModel.fromJson(response as Map<String, dynamic>);
      }
      return DashboardSummaryModel.empty();
    } catch (e) {
      print('>>> Error fetching dashboard summary: $e');
      // Mock data to test UI
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

  Future<List<ProviderBookingModel>> fetchUpcomingBookings() async {
    try {
      final response = await _supabase.rpc('get_provider_upcoming_bookings');

      if (response != null && response is List) {
        return response
            .map(
              (e) => ProviderBookingModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('>>> Error fetching upcoming bookings: $e');
      // Mock data to test UI
      return [
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
      ];
    }
  }
}
