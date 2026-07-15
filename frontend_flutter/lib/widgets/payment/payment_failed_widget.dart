// lib/widgets/payment/payment_failed_widget.dart

import 'package:flutter/material.dart';

class PaymentFailedWidget extends StatelessWidget {
  final String status;
  final Color primaryColor;

  const PaymentFailedWidget({
    super.key,
    required this.status,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = status == 'EXPIRED';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 80),
        const SizedBox(height: 16),
        Text(
          isExpired ? 'Thanh toán đã bị hủy' : 'Thanh toán thất bại',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Vui lòng thử lại hoặc chọn phương thức khác.'),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }
}