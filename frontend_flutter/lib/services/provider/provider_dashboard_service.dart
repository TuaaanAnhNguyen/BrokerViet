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

      // Edge Function trả 401 kèm { error: ... } khi chưa đăng nhập,
      // hoặc RPC báo lỗi qua status 400/500 -> đều không phải payload hợp lệ
      if (response.status != 200 ||
          data == null ||
          data is! Map<String, dynamic>) {
        throw Exception(data is Map ? data['error'] : 'Unknown error');
      }

      return DashboardSummaryModel.fromJson(data);
    } catch (e) {
      print('>>> Error fetching dashboard summary: $e');
      return DashboardSummaryModel.empty();
    }
  }

  Future<List<ProviderBookingModel>> fetchUpcomingBookings() async {
    try {
      final response = await _supabase.functions.invoke(
        'get-provider-upcoming-bookings',
      );

      final data = response.data;
      print('>>> FETCHING BOOKINGS: $data');

      if (response.status == 200 &&
          data is Map<String, dynamic> &&
          data['items'] is List) {
        final items = data['items'] as List;
        return items
            .map(
              (e) => ProviderBookingModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('>>> Error fetching upcoming bookings: $e');
      return [];
    }
  }
}
