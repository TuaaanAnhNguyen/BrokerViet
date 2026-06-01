// lib/features/main/notification_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _simulateFetchFromBackend();
  }

  Future<void> _simulateFetchFromBackend() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      setState(() {
        _notifications = [
          NotificationModel(
            id: '1',
            title: 'Booking Confirmed 🛠️',
            body: 'Technician Nguyen Van A has accepted your Laptop Clean & Paste request.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
            iconType: Icons.build_circle_outlined,
          ),
          NotificationModel(
            id: '2',
            title: 'New Chat Message 💬',
            body: 'TechCare Danang sent: "Can you send over the current system specs?"',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            iconType: Icons.chat_bubble_outline,
          ),
          NotificationModel(
            id: '3',
            title: 'Hardware Rental Returned 📦',
            body: 'Your active rental for RTX 4060 GPU card has been processed cleanly.',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
            iconType: Icons.assignment_turned_in_outlined,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () {
                setState(() {
                  _notifications = _notifications.map((n) => NotificationModel(
                    id: n.id, title: n.title, body: n.body, createdAt: n.createdAt, iconType: n.iconType, isRead: true
                  )).toList();
                });
              },
            )
        ],
      ),
      
      body: _buildBodyState(),
    );
  }

  Widget _buildBodyState() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'All Caught Up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            const Text(
              'New alerts regarding service repairs will display here.',
              style: TextStyle(fontSize: 14, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _notifications.length,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return NotificationTile(
          notification: item,
          onTap: () {
            setState(() {
              _notifications[index] = NotificationModel(
                id: item.id,
                title: item.title,
                body: item.body,
                createdAt: item.createdAt,
                iconType: item.iconType,
                isRead: true,
              );
            });
          },
        );
      },
    );
  }
}