// lib/widgets/booking/booking_bill_details_section.dart

import 'package:flutter/material.dart';

class BookingBillDetailsSection extends StatelessWidget {
  final String packageName;
  final double serviceFee;
  final double totalAmount;
  final String Function(double) formatCurrency;

  const BookingBillDetailsSection({
    super.key,
    required this.packageName,
    required this.serviceFee,
    required this.totalAmount,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết hóa đơn',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí dịch vụ ($packageName)',
                style: const TextStyle(color: bodyText, fontSize: 13),
              ),
              Text(
                formatCurrency(serviceFee),
                style: const TextStyle(color: bodyText, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 24, thickness: 0.5, color: outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              Text(
                formatCurrency(totalAmount),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
