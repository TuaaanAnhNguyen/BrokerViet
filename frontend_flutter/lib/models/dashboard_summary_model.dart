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
    return DashboardSummaryModel(
      todaysBookings:
          int.tryParse(json['todaysBookings']?.toString() ?? '0') ?? 0,
      pendingRequests:
          int.tryParse(json['pendingRequests']?.toString() ?? '0') ?? 0,
      // revenueToday / monthlyRevenue đã được RPC format sẵn thành chuỗi
      // (vd: "1,250,000 đ") qua to_char(), dùng thẳng không cần NumberFormat nữa.
      revenueToday: json['revenueToday']?.toString() ?? '0 đ',
      monthlyRevenue: json['monthlyRevenue']?.toString() ?? '0 đ',
      averageRating:
          double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      totalCompletedJobs:
          int.tryParse(json['totalCompletedJobs']?.toString() ?? '0') ?? 0,
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
