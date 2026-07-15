// lib/widgets/booking/invoice_breakdown_card.dart

import 'package:flutter/material.dart';

class InvoiceBreakdownCard extends StatelessWidget {
  final String packageName;
  final double serviceFee;
  final double discountAmount;
  final double totalAmount;
  final String? appliedVoucherCode;

  const InvoiceBreakdownCard({
    super.key,
    required this.packageName,
    required this.serviceFee,
    required this.discountAmount,
    required this.totalAmount,
    this.appliedVoucherCode,
  });

  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
  }

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
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.3),
        ),
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
          _buildBillRow(
            'Phí dịch vụ ($packageName)',
            _formatCurrency(serviceFee),
            bodyText,
          ),
          if (appliedVoucherCode != null) ...[
            const SizedBox(height: 6),
            _buildBillRow(
              'Giảm giá voucher',
              '-${_formatCurrency(discountAmount)}',
              Colors.green.shade700,
            ),
          ],
          const SizedBox(height: 6),
          const Divider(
            height: 24,
            thickness: 0.5,
            color: outlineVariant,
          ),
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
                _formatCurrency(totalAmount),
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

  Widget _buildBillRow(String label, String cost, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
          ),
        ),
        Text(
          cost,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}