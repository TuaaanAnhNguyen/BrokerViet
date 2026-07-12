// lib/widgets/booking/booking_payment_selector.dart

import 'package:flutter/material.dart';

class BookingPaymentSelector extends StatelessWidget {
  final int selectedMethod;
  final ValueChanged<int> onMethodChanged;

  const BookingPaymentSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Column(
      children: [
        _buildPaymentRow(
          0,
          Icons.qr_code_2,
          'Chuyển khoản Online (VietQR)',
          'Quét mã QR nhanh chóng qua ứng dụng ngân hàng',
          primaryColor,
          outlineVariant,
        ),
        const SizedBox(height: 8),
        _buildPaymentRow(
          1,
          Icons.credit_card,
          'Thẻ Tín dụng / Ghi nợ',
          'Visa, Mastercard, JCB',
          primaryColor,
          outlineVariant,
        ),
        const SizedBox(height: 8),
        _buildPaymentRow(
          3,
          Icons.account_balance_wallet_outlined,
          'VNPAY Gateway',
          'Thanh toán qua ứng dụng VNPAY hoặc Ngân hàng',
          primaryColor,
          outlineVariant,
        ),
        const SizedBox(height: 8),
        _buildPaymentRow(
          2,
          Icons.payments,
          'Tiền mặt sau dịch vụ',
          'Thanh toán sau khi hoàn thành sửa chữa',
          primaryColor,
          outlineVariant,
        ),
      ],
    );
  }

  Widget _buildPaymentRow(
    int index,
    IconData icon,
    String title,
    String subtitle,
    Color activeColor,
    Color defaultOutline,
  ) {
    final isSelected = selectedMethod == index;
    return GestureDetector(
      onTap: () => onMethodChanged(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : defaultOutline.withAlpha(153),
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
                border: Border.all(color: defaultOutline.withAlpha(127)),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : const Color(0xFF434655),
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
                  color: isSelected ? activeColor : defaultOutline,
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
                          color: activeColor,
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
