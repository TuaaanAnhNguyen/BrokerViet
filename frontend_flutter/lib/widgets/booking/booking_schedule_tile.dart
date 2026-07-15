// lib/widgets/booking/booking_schedule_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingScheduleTile extends StatelessWidget {
  final DateTime scheduledAt;

  const BookingScheduleTile({
    super.key,
    required this.scheduledAt,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thời gian đã chọn lịch',
                  style: TextStyle(fontSize: 12, color: bodyText),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, dd MMMM, yyyy - HH:mm', 'vi').format(scheduledAt),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}