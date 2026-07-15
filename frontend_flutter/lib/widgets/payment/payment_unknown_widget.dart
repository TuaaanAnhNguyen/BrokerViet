// lib/widgets/payment/payment_unknown_widget.dart

import 'package:flutter/material.dart';

class PaymentUnknownWidget extends StatelessWidget {
  final Color primaryColor;

  const PaymentUnknownWidget({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.help_outline, color: Colors.orange, size: 80),
        const SizedBox(height: 16),
        const Text(
          'Trạng thái không xác định',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Chúng tôi chưa nhận được phản hồi từ VNPay. Vui lòng kiểm tra lại sau.'),
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