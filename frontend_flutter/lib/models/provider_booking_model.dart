// lib/models/provider_booking_model.dart

import 'booking_model.dart';
import 'package:intl/intl.dart';

class ProviderBookingModel {
  final String bookingId;
  final String customerName;
  final String? customerAvatar;
  final String serviceTitle;
  final DateTime? date;
  final BookingStatus status;
  final double? price;
  final String? address;
  final String? customerNotes;
  final DateTime? requestedAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;

  const ProviderBookingModel({
    required this.bookingId,
    required this.customerName,
    this.customerAvatar,
    required this.serviceTitle,
    this.date,
    required this.status,
    this.price,
    this.address,
    this.customerNotes,
    this.requestedAt,
    this.confirmedAt,
    this.completedAt,
  });

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['scheduled_at'] != null) {
      parsedDate = DateTime.tryParse(json['scheduled_at'].toString());
    } else if (json['booked_at'] != null) {
      parsedDate = DateTime.tryParse(json['booked_at'].toString());
    }

    return ProviderBookingModel(
      bookingId: json['booking_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Khách hàng',
      customerAvatar: json['customer_avatar']?.toString(),
      serviceTitle: json['service_type']?.toString() ??
          json['service_title']?.toString() ??
          'Dịch vụ',
      date: parsedDate,
      // Fixed: Directly parsing standard DB string now
      status: BookingStatus.fromDbString(json['status']?.toString() ?? ''),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      address: json['address']?.toString(),
      customerNotes: json['customer_notes']?.toString(),
      requestedAt: json['requested_at'] != null ? DateTime.tryParse(json['requested_at'].toString()) : null,
      confirmedAt: json['confirmed_at'] != null ? DateTime.tryParse(json['confirmed_at'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null,
    );
  }

  String get formattedDate {
    if (date == null) return 'Không xác định';
    return DateFormat('dd/MM/yyyy HH:mm').format(date!);
  }
}