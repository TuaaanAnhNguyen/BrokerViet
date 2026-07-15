// lib/widgets/payment/payment_success_widget.dart

import 'package:flutter/material.dart';

class PaymentSuccessWidget extends StatelessWidget {
  final String bookingId;
  final Color primaryColor;

  const PaymentSuccessWidget({
    super.key,
    required this.bookingId,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Trích xuất mã ID ngắn gọn để hiển thị
    final shortId = bookingId.length > 8 ? bookingId.substring(0, 8) : bookingId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 16),
        const Text(
          'Thanh toán thành công!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Đơn hàng #$shortId đã được thanh toán.'),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Quay lại trang chủ'),
          ),
        ),
      ],
    );
  }
}