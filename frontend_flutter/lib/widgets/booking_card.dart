// lib/features/widgets/booking_card.dart

import 'package:broker_viet/widgets/network_image_fallback.dart';
import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel order;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;
  final VoidCallback? TrackProgress;

  const BookingCard({
    super.key,
    required this.order,
    this.onCancel,
    this.onRebook,
    this.TrackProgress,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    Color statusColor;
    switch (order.status) {
      case BookingStatus.daHoanThanh:
        statusColor = const Color(0xFF2E7D32);
        break;
      case BookingStatus.dangThucHien:
        statusColor = primaryColor;
        break;
      case BookingStatus.choDuyet:
        statusColor = const Color(0xFFE65100);
        break;
      case BookingStatus.daHuy:
        statusColor = Colors.red.shade700;
        break;
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'Nơi cung cấp:',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.shopName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: darkText,
                    ),
                  ),
                ],
              ),
              Text(
                order.status.value,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: outlineVariant.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: NetworkImageWithFallback(
                    imageUrl: order.imageUrl,
                    width: 76,
                    height: 76,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: darkText,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
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
                      child: Text(
                        'x1',
                        style: TextStyle(color: bodyText, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: darkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.5, color: outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Thành tiền (1 dịch vụ): ',
                style: TextStyle(fontSize: 13, color: bodyText),
              ),
              Text(
                order.cost,
                style: const TextStyle(
                  fontSize: 16,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);

    final ButtonStyle secondaryStyle = OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFFC3C6D7)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );

    final ButtonStyle primaryStyle = OutlinedButton.styleFrom(
      side: const BorderSide(color: primaryColor),
      backgroundColor: const Color(0xFFEFF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );

    switch (order.status) {
      case BookingStatus.daHoanThanh:
        return [
          OutlinedButton(
            onPressed: () {},
            style: secondaryStyle,
            child: const Text(
              'Xem đánh giá',
              style: TextStyle(color: darkText, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onRebook,
            style: primaryStyle,
            child: const Text(
              'Đặt lịch lại',
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      case BookingStatus.dangThucHien:
        return [
          OutlinedButton(
            onPressed: TrackProgress,
            style: primaryStyle,
            child: const Text(
              'Theo dõi tiến độ',
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      case BookingStatus.choDuyet:
        return [
          OutlinedButton(
            onPressed: onCancel,
            style: secondaryStyle,
            child: const Text(
              'Hủy yêu cầu',
              style: TextStyle(color: darkText, fontSize: 13),
            ),
          ),
        ];
      case BookingStatus.daHuy:
        return [
          OutlinedButton(
            onPressed: () {},
            style: secondaryStyle,
            child: const Text(
              'Xem chi tiết',
              style: TextStyle(color: darkText, fontSize: 13),
            ),
          ),
        ];
    }
  }
}