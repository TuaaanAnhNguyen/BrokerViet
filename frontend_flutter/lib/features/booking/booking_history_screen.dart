// lib/features/booking/booking_history_screen.dart

import 'package:flutter/material.dart';

class BookingModel {
  final String bookingId;
  final String shopName;
  final String serviceTitle;
  final String imageUrl;
  final String variantDetails;
  final String date;
  final String originalCost;
  final String cost;
  final String status; // 'Chờ duyệt', 'Đang thực hiện', 'Đã hoàn thành', 'Đã hủy'

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
}

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  final List<BookingModel> _mockBookings = const [
    BookingModel(
      bookingId: 'BV-9831',
      shopName: 'TechCare Pro Service',
      serviceTitle: 'Vệ sinh PC chuyên sâu & Tối ưu hóa keo tản nhiệt',
      imageUrl: 'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=150',
      variantDetails: 'Thermal Grizzly, Máy tính bàn Tiêu chuẩn',
      date: '01 Tháng 6 2026',
      originalCost: '350.000đ',
      cost: '250.000đ',
      status: 'Đang thực hiện',
    ),
    BookingModel(
      bookingId: 'BV-9210',
      shopName: 'An Phát Computer',
      serviceTitle: 'Bàn phím cơ DareU EK87L V2 Black no LED',
      imageUrl: 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=150',
      variantDetails: 'Dream Switch, Màu Đen',
      date: '25 Tháng 5 2026',
      originalCost: '499.000đ',
      cost: '289.000đ',
      status: 'Đã hoàn thành',
    ),
    BookingModel(
      bookingId: 'BV-1102',
      shopName: 'Blood Lab Center',
      serviceTitle: 'Xét nghiệm lâm sàng & Đánh giá chỉ số sinh học',
      imageUrl: 'https://images.unsplash.com/photo-1579165466541-7183b6f6943a?w=150',
      variantDetails: 'Gói Xét nghiệm Tiêu chuẩn Hỏa tốc',
      date: '12 Tháng 5 2026',
      originalCost: '600.000đ',
      cost: '600.000đ',
      status: 'Chờ duyệt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> statuses = ['Tất cả', 'Chờ duyệt', 'Đang thực hiện', 'Đã hoàn thành', 'Đã hủy'];
    const Color primaryColor = Color(0xFF004AC6);

    return DefaultTabController(
      length: statuses.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Đơn đã mua',
            style: TextStyle(color: Color(0xFF0B1C30), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: const Color(0xFFC3C6D7).withOpacity(0.5))),
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: const Color(0xFF434655),
                indicatorColor: primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: statuses.map((status) => Tab(text: status)).toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: statuses.map((status) {
            final filteredBookings = status == 'Tất cả'
                ? _mockBookings
                : _mockBookings.where((item) => item.status.toLowerCase() == status.toLowerCase()).toList();

            return filteredBookings.isEmpty
                ? const Center(child: Text('Không tìm thấy đơn hàng nào.', style: TextStyle(color: Color(0xFF434655))))
                : ListView.builder(
                    itemCount: filteredBookings.length,
                    padding: const EdgeInsets.only(top: 8),
                    itemBuilder: (context, index) {
                      return _buildShopeeStyleCard(filteredBookings[index]);
                    },
                  );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildShopeeStyleCard(BookingModel order) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    String visibleStatusText = order.status;
    Color statusColor = primaryColor;

    if (order.status == 'Đã hoàn thành') {
      statusColor = const Color(0xFF2E7D32); // Xanh lá cho trạng thái hoàn thành
    } else if (order.status == 'Đang thực hiện') {
      statusColor = primaryColor;
    } else if (order.status == 'Chờ duyệt') {
      statusColor = const Color(0xFFE65100); // Cam/Hổ phách cho trạng thái chờ duyệt
    } else if (order.status == 'Đã hủy') {
      statusColor = Colors.red.shade700;
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header (Đối tác cung cấp + Trạng thái đơn)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Nơi cung cấp:',
                      style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.shopName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText),
                  ),
                ],
              ),
              Text(
                visibleStatusText,
                style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 2: Nội dung dịch vụ/sản phẩm chính
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  border: Border.all(color: outlineVariant.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(order.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceTitle,
                      style: const TextStyle(fontSize: 14, color: darkText, fontWeight: FontWeight.w500, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phân loại: ${order.variantDetails}',
                      style: const TextStyle(color: bodyText, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('x1', style: TextStyle(color: bodyText, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Giá gốc và giá giảm
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (order.originalCost != order.cost)
                Text(
                  order.originalCost,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              if (order.originalCost != order.cost) const SizedBox(width: 6),
              Text(
                order.cost,
                style: const TextStyle(fontSize: 14, color: darkText, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.5, color: outlineVariant),

          // Row 4: Tổng số tiền tính toán
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Thành tiền (1 dịch vụ): ',
                style: TextStyle(fontSize: 13, color: bodyText),
              ),
              Text(
                order.cost,
                style: const TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 5: Khối các nút tương tác hành động đơn hàng
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildActionButtons(order.status),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(String status) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);

    final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFFC3C6D7)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );

    final ButtonStyle primaryButtonStyle = OutlinedButton.styleFrom(
      side: const BorderSide(color: primaryColor),
      backgroundColor: const Color(0xFFEFF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );

    switch (status) {
      case 'Đã hoàn thành':
        return [
          OutlinedButton(
            onPressed: () {},
            style: secondaryButtonStyle,
            child: const Text('Xem đánh giá', style: TextStyle(color: darkText, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {},
            style: primaryButtonStyle,
            child: const Text('Đặt lịch lại', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ];
      case 'Đang thực hiện':
        return [
          OutlinedButton(
            onPressed: () {},
            style: primaryButtonStyle,
            child: const Text('Theo dõi tiến độ', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ];
      case 'Chờ duyệt':
        return [
          OutlinedButton(
            onPressed: () {},
            style: secondaryButtonStyle,
            child: const Text('Hủy yêu cầu', style: TextStyle(color: darkText, fontSize: 13)),
          ),
        ];
      default:
        return [
          OutlinedButton(
            onPressed: () {},
            style: secondaryButtonStyle,
            child: const Text('Xem chi tiết', style: TextStyle(color: darkText, fontSize: 13)),
          ),
        ];
    }
  }
}