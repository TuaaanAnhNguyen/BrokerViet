// lib/models/booking_model.dart

enum BookingStatus {
  choDuyet('Chờ duyệt'),
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
}
