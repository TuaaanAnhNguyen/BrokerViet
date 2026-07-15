// lib/models/booking_model.dart

enum BookingStatus {
  dangChoDuyet('PENDING', 'Đang chờ duyệt'),
  daHoanThanh('COMPLETED', 'Đã hoàn thành'),
  daHuy('CANCELLED', 'Đã hủy');

  final String dbValue;
  final String uiLabel;
  const BookingStatus(this.dbValue, this.uiLabel);

  // Safely parse database strings (e.g., 'PENDING', 'completed') into the Enum
  static BookingStatus fromDbString(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.dbValue.toLowerCase() == status.trim().toLowerCase(),
      orElse: () => BookingStatus.dangChoDuyet, // Fallback default
    );
  }

  // Convert to database string when writing to Supabase
  String toDbString() => dbValue;
}

class BookingModel {
  final String bookingId;
  final String shopName;
  final String serviceTitle;
  final String imageUrl;
  final String variantDetails;
  final String date;
  final String originalCost;
  final String cost;
  final BookingStatus status;

  const BookingModel({
    required this.bookingId,
    required this.shopName,
    required this.serviceTitle,
    required this.imageUrl,
    required this.variantDetails,
    required this.date,
    required this.originalCost,
    required this.cost,
    required this.status,
  });

  BookingModel copyWith({BookingStatus? status}) {
    return BookingModel(
      bookingId: bookingId,
      shopName: shopName,
      serviceTitle: serviceTitle,
      imageUrl: imageUrl,
      variantDetails: variantDetails,
      date: date,
      originalCost: originalCost,
      cost: cost,
      status: status ?? this.status,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['booking_id']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? 'Cửa hàng đối tác',
      serviceTitle:
          json['service_type']?.toString() ??
          json['service_title']?.toString() ??
          'Dịch vụ hệ thống',
      imageUrl:
          (json['image_url'] != null && json['image_url'].toString().isNotEmpty)
          ? json['image_url'].toString()
          : 'assets/no_icon_placeholder.png',
      variantDetails: json['variant_details']?.toString() ?? 'Tiêu chuẩn',
      date:
          json['scheduled_at']?.toString() ??
          json['booked_at']?.toString() ??
          '',
      originalCost: '${json['total_price'] ?? 0} đ',
      cost: '${json['total_price'] ?? 0} đ',
      status: BookingStatus.fromDbString(json['status']?.toString() ?? ''),
    );
  }
}
