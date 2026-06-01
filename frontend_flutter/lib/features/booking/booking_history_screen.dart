// lib/features/booking/booking_history_screen.dart
import 'package:flutter/material.dart';

class BookingModel {
  final String bookingId;
  final String serviceTitle;
  final String date;
  final String cost;
  final String status; // 'Pending', 'In-Repair', 'Completed'

  const BookingModel({
    required this.bookingId,
    required this.serviceTitle,
    required this.date,
    required this.cost,
    required this.status,
  });
}

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  final List<BookingModel> _mockBookings = const [
    BookingModel(bookingId: 'BV-9831', serviceTitle: 'Deep PC Cleaning & Thermal Paste', date: '01 June 2026', cost: '250.000đ', status: 'In-Repair'),
    BookingModel(bookingId: 'BV-9210', serviceTitle: 'RTX 4060 GPU Weekly Rental', date: '25 May 2026', cost: '500.000đ', status: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _mockBookings.isEmpty
          ? const Center(child: Text('No repair orders found.'))
          : ListView.builder(
              itemCount: _mockBookings.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = _mockBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.bookingId,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          order.serviceTitle,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date: ${order.date}', style: const TextStyle(color: Colors.black38, fontSize: 13)),
                            Text(order.cost, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;

    switch (status) {
      case 'In-Repair':
        badgeColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'Completed':
        badgeColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      default:
        badgeColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}