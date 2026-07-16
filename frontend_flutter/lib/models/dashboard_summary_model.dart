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
    double parsedRating = 0.0;
    if (json['averageRating'] != null) {
      parsedRating =
          num.tryParse(json['averageRating'].toString())?.toDouble() ?? 0.0;
    }

    return DashboardSummaryModel(
      todaysBookings:
          int.tryParse(json['todaysBookings']?.toString() ?? '0') ?? 0,
      pendingRequests:
          int.tryParse(json['pendingRequests']?.toString() ?? '0') ?? 0,

      revenueToday: json['revenueToday']?.toString() ?? '0 đ',
      monthlyRevenue: json['monthlyRevenue']?.toString() ?? '0 đ',

      averageRating: parsedRating,
      totalCompletedJobs:
          int.tryParse(json['totalCompletedJobs']?.toString() ?? '0') ?? 0,
    );
  }

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
