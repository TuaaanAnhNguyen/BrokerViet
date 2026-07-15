// lib/widgets/payment/payment_pending_widget.dart

import 'package:flutter/material.dart';

class PaymentPendingWidget extends StatelessWidget {
  const PaymentPendingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Colors.blue),
        SizedBox(height: 16),
        Text('Đang kiểm tra trạng thái thanh toán...'),
      ],
    );
  }
}