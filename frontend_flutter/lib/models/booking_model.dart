// lib/models/booking_model.dart

enum BookingStatus {
  choDuyet('Chờ duyệt'),
  xacNhan('Đã xác nhận'),
  dangThucHien('Đang thực hiện'),
  daHoanThanh('Đã hoàn thành'),
  daHuy('Đã hủy');

  final String value;
  const BookingStatus(this.value);

  static BookingStatus fromString(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == status.toLowerCase(),
      orElse: () => BookingStatus.choDuyet,
    );
  }

  String toDbString() {
    switch (this) {
      case BookingStatus.choDuyet:
        return 'pending';
      case BookingStatus.xacNhan:
        return 'confirmed';
      case BookingStatus.dangThucHien:
        return 'ongoing';
      case BookingStatus.daHoanThanh:
        return 'completed';
      case BookingStatus.daHuy:
        return 'cancelled';
    }
  }
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
      serviceTitle: json['service_type']?.toString() ??
          json['service_title']?.toString() ??
          'Dịch vụ hệ thống',
      // Falls back to local asset path string if backend image is null or empty
      imageUrl: (json['image_url'] != null && json['image_url'].toString().isNotEmpty)
          ? json['image_url'].toString()
          : 'assets/no_icon_placeholder.png',
      variantDetails: json['variant_details']?.toString() ?? 'Tiêu chuẩn',
      date: json['scheduled_at']?.toString() ?? json['booked_at']?.toString() ?? '',
      originalCost: '${json['total_price'] ?? 0} đ',
      cost: '${json['total_price'] ?? 0} đ',
      status: BookingStatus.fromString(
        _mapDbStatusToVietnamese(json['status']?.toString() ?? ''),
      ),
    );
  }

  // Hàm phụ trợ map từ trạng thái database sang String value của Enum
  static String _mapDbStatusToVietnamese(String dbStatus) {
    switch (dbStatus.toLowerCase()) {
      case 'pending':
      case 'cho_duyet':
        return 'Chờ duyệt';
      case 'confirmed':
      case 'xac_nhan':
        return 'Đã xác nhận';
      case 'ongoing':
      case 'dang_thuc_hien':
        return 'Đang thực hiện';
      case 'completed':
      case 'da_hoan_thanh':
        return 'Đã hoàn thành';
      case 'cancelled':
      case 'da_huy':
        return 'Đã hủy';
      default:
        return dbStatus; // Nếu backend trả thẳng tiếng Việt thì giữ nguyên
    }
  }
}
