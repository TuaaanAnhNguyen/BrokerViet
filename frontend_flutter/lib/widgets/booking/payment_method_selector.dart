// lib/widgets/booking/payment_method_selector.dart

import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  final int selectedPaymentMethod;
  final ValueChanged<int> onMethodChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selectedPaymentMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức thanh toán',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 10),
        _buildPaymentRow(
          index: 0,
          icon: Icons.qr_code_2,
          title: 'Chuyển khoản Online (VietQR)',
          subtitle: 'Quét mã QR nhanh chóng qua ứng dụng ngân hàng',
          primaryColor: primaryColor,
          outlineVariant: outlineVariant,
        ),
        const SizedBox(height: 8),
        _buildPaymentRow(
          index: 3,
          icon: Icons.account_balance_wallet_outlined,
          title: 'VNPAY Gateway',
          subtitle: 'Thanh toán qua ứng dụng VNPAY hoặc Ngân hàng',
          primaryColor: primaryColor,
          outlineVariant: outlineVariant,
        ),
        const SizedBox(height: 8),
        _buildPaymentRow(
          index: 2,
          icon: Icons.payments,
          title: 'Tiền mặt sau dịch vụ',
          subtitle: 'Thanh toán sau khi hoàn thành sửa chữa',
          primaryColor: primaryColor,
          outlineVariant: outlineVariant,
        ),
      ],
    );
  }

  Widget _buildPaymentRow({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required Color outlineVariant,
  }) {
    final isSelected = selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => onMethodChanged(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : const Color(0xFF434655),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF434655),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}