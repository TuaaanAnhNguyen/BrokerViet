// lib/services/booking/booking_service.dart

import '../../models/booking_model.dart';

class BookingService {
  // Simulate network/database latency
  Future<List<BookingModel>> fetchBookings() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const BookingModel(
        bookingId: 'BV-9831',
        shopName: 'TechCare Pro Service',
        serviceTitle: 'Vệ sinh PC chuyên sâu & Tối ưu hóa keo tản nhiệt',
        imageUrl:
            'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=150',
        variantDetails: 'Thermal Grizzly, Máy tính bàn Tiêu chuẩn',
        date: '01 Tháng 6 2026',
        originalCost: '350.000đ',
        cost: '250.000đ',
        status: BookingStatus.dangThucHien,
      ),
      const BookingModel(
        bookingId: 'BV-9210',
        shopName: 'An Phát Computer',
        serviceTitle: 'Bàn phím cơ DareU EK87L V2 Black no LED',
        imageUrl:
            'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=150',
        variantDetails: 'Dream Switch, Màu Đen',
        date: '25 Tháng 5 2026',
        originalCost: '499.000đ',
        cost: '289.000đ',
        status: BookingStatus.daHoanThanh,
      ),
      const BookingModel(
        bookingId: 'BV-1102',
        shopName: 'Blood Lab Center',
        serviceTitle: 'Xét nghiệm lâm sàng & Đánh giá chỉ số sinh học',
        imageUrl:
            'https://images.unsplash.com/photo-1579165466541-7183b6f6943a?w=150',
        variantDetails: 'Gói Xét nghiệm Tiêu chuẩn Hỏa tốc',
        date: '12 Tháng 5 2026',
        originalCost: '600.000đ',
        cost: '600.000đ',
        status: BookingStatus.choDuyet,
      ),
    ];
  }

  Future<bool> cancelBookingRequest(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Simulate successful response update from API
  }
}
