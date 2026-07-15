// lib/widgets/booking_card.dart

import 'package:broker_viet/widgets/network_image_fallback.dart';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';

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

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Chưa rõ';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      if (dateStr.length >= 10) {
        return dateStr.substring(0, 10).split('-').reversed.join('/');
      }
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFE5E7EB);

    Color statusColor;
    switch (order.status) {
      case BookingStatus.daHoanThanh:
        statusColor = const Color(0xFF2E7D32);
        break;
      case BookingStatus.dangChoDuyet:
        statusColor = const Color(0xFFE65100);
        break;
      case BookingStatus.daHuy:
        statusColor = Colors.red.shade700;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Store Icon + Name + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.shopName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.status.uiLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Service details: image + title/variant + quantity & price & date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageWithFallback(
                  imageUrl: order.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
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
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phân loại: ${order.variantDetails}',
                      style: const TextStyle(color: bodyText, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Price + Quantity + Date (all in one highly readable line)
                    Text(
                      '${order.cost}  •  SL: 1  •  Ngày: ${_formatDate(order.date)}',
                      style: const TextStyle(
                        color: bodyText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: outlineVariant),
          const SizedBox(height: 10),
          // Footer: Total Price & Action buttons next to each other
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(fontSize: 10, color: bodyText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.cost,
                    style: const TextStyle(
                      fontSize: 15,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildActionButtons(),
              ),
            ],
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
      case BookingStatus.dangChoDuyet:
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