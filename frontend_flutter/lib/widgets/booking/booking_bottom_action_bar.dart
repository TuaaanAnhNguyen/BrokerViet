// lib/widgets/booking/booking_bottom_action_bar.dart

import 'package:flutter/material.dart';

class BookingBottomActionBar extends StatelessWidget {
  final double totalAmount;
  final bool isSubmitting;
  final VoidCallback onSubmitPressed;
  final String Function(double) formatCurrency;

  const BookingBottomActionBar({
    super.key,
    required this.totalAmount,
    required this.isSubmitting,
    required this.onSubmitPressed,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: outlineVariant.withAlpha(127))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Giá thanh toán cuối',
                      style: TextStyle(fontSize: 12, color: bodyText),
                    ),
                    Text(
                      formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.verified_user, color: bodyText, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Thanh toán bảo mật',
                      style: TextStyle(fontSize: 12, color: bodyText),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isSubmitting ? null : onSubmitPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Xác nhận đặt lịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 11, color: bodyText),
                children: [
                  TextSpan(
                    text:
                        'Bằng việc nhấn nút "Xác nhận đặt lịch", bạn đồng ý với ',
                  ),
                  TextSpan(
                    text: 'Điều khoản dịch vụ',
                    style: TextStyle(
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' của chúng tôi.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
