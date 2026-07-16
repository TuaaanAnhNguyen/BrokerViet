// lib/models/booking_model.dart

enum BookingStatus {
  dangChoDuyet('PENDING', 'Đang chờ duyệt'),
  daChapNhan('ACCEPTED', 'Đã chấp nhận'),
  daBiHuy('REJECTED', 'Đã bị huỷ'),
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
  final String serviceId;
  final String customerId;
  final String providerId;
  final int totalPrice;
  final String? serviceType;

  const BookingModel({
    required this.bookingId,
    required this.serviceId,
    required this.customerId,
    required this.providerId,
    required this.shopName,
    required this.serviceTitle,
    required this.imageUrl,
    required this.variantDetails,
    required this.date,
    required this.originalCost,
    required this.cost,
    required this.totalPrice,
    required this.status,
    this.serviceType,
  });

  BookingModel copyWith({BookingStatus? status}) {
    return BookingModel(
      bookingId: bookingId,
      serviceId: serviceId,
      customerId: customerId,
      providerId: providerId,
      shopName: shopName,
      serviceTitle: serviceTitle,
      imageUrl: imageUrl,
      variantDetails: variantDetails,
      date: date,
      originalCost: originalCost,
      cost: cost,
      totalPrice: totalPrice,
      status: status ?? this.status,
      serviceType: serviceType,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final price = json['total_price'] ?? 0;

    return BookingModel(
      bookingId: json['booking_id']?.toString() ?? '',

      serviceId: json['service_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',

      shopName: json['shop_name']?.toString() ?? 'Cửa hàng đối tác',

      serviceTitle:
          json['service_type']?.toString() ??
          json['service_title']?.toString() ??
          'Dịch vụ',

      imageUrl:
          (json['image_url'] != null && json['image_url'].toString().isNotEmpty)
          ? json['image_url'].toString()
          : 'assets/no_icon_placeholder.png',

      variantDetails: json['variant_details']?.toString() ?? 'Tiêu chuẩn',

      date:
          json['scheduled_at']?.toString() ??
          json['booked_at']?.toString() ??
          '',

      totalPrice: price,

      originalCost: '$price đ',
      cost: '$price đ',

      serviceType: json['service_type']?.toString(),

      status: BookingStatus.fromDbString(json['status']?.toString() ?? ''),
    );
  }
}
