import 'package:intl/intl.dart';

class DashboardSummaryModel {
  final int todaysBookings;
  final int pendingRequests;
  final String revenueToday;
  final String monthlyRevenue;
  final double averageRating;
  final int totalCompletedJobs;

  const DashboardSummaryModel({
    required this.todaysBookings,
    required this.pendingRequests,
    required this.revenueToday,
    required this.monthlyRevenue,
    required this.averageRating,
    required this.totalCompletedJobs,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    double revToday = 0;
    if (json['revenue_today'] != null) {
      revToday = double.tryParse(json['revenue_today'].toString()) ?? 0;
    }

    double revMonth = 0;
    if (json['monthly_revenue'] != null) {
      revMonth = double.tryParse(json['monthly_revenue'].toString()) ?? 0;
    }

    return DashboardSummaryModel(
      todaysBookings: int.tryParse(json['todays_bookings']?.toString() ?? '0') ?? 0,
      pendingRequests: int.tryParse(json['pending_requests']?.toString() ?? '0') ?? 0,
      revenueToday: currencyFormatter.format(revToday),
      monthlyRevenue: currencyFormatter.format(revMonth),
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      totalCompletedJobs: int.tryParse(json['total_completed_jobs']?.toString() ?? '0') ?? 0,
    );
  }

  // Factory for an empty/default state when there is no data
  factory DashboardSummaryModel.empty() {
    return const DashboardSummaryModel(
      todaysBookings: 0,
      pendingRequests: 0,
      revenueToday: '0 đ',
      monthlyRevenue: '0 đ',
      averageRating: 0.0,
      totalCompletedJobs: 0,
    );
  }
}
