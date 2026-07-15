// lib/models/dashboard_summary_model.dart

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
    // 1. Safe parsing for averageRating (converts int or double safely into double)
    double parsedRating = 0.0;
    if (json['averageRating'] != null) {
      parsedRating =
          num.tryParse(json['averageRating'].toString())?.toDouble() ?? 0.0;
    }

    return DashboardSummaryModel(
      // 2. Map exactly to the camelCase keys returned by your PostgreSQL jsonb_build_object
      todaysBookings:
          int.tryParse(json['todaysBookings']?.toString() ?? '0') ?? 0,
      pendingRequests:
          int.tryParse(json['pendingRequests']?.toString() ?? '0') ?? 0,

      // 3. The database function already returns formatted strings like "90,000 đ" or "0 đ"
      revenueToday: json['revenueToday']?.toString() ?? '0 đ',
      monthlyRevenue: json['monthlyRevenue']?.toString() ?? '0 đ',

      averageRating: parsedRating,
      totalCompletedJobs:
          int.tryParse(json['totalCompletedJobs']?.toString() ?? '0') ?? 0,
    );
  }

  // Factory for an empty/default state when there is no data or an exception occurs
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
