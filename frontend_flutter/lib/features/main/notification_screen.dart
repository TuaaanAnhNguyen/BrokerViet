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
            title: 'Yêu cầu Đang được Xử lý',
            body:
                'Kỹ thuật viên Nguyễn Văn A đã tiếp nhận đơn đặt lịch Vệ sinh & Tra keo tản nhiệt máy tính của bạn.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
            status: 'In Progress',
          ),
          NotificationModel(
            id: '2',
            title: 'Đơn hàng Chờ Xác nhận',
            body:
                'Đơn đặt lịch kiểm tra hệ thống của bạn đã được gửi thành công và đang chờ đối tác phản hồi.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            status: 'In Review',
          ),
          NotificationModel(
            id: '3',
            title: 'Hoàn thành Dịch vụ',
            body:
                'Yêu cầu hỗ trợ cấu hình và lắp đặt card đồ họa RTX của bạn đã hoàn tất bàn giao.',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
            status: 'Done',
          ),
          NotificationModel(
            id: '4',
            title: 'Đơn hàng đã Hủy',
            body:
                'Yêu cầu sửa chữa thiết bị phần cứng mã đơn #BK-9912 đã bị hủy theo nguyện vọng của khách hàng.',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            isRead: true,
            status: 'Cancelled',
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: primaryColor),
              tooltip: 'Đánh dấu tất cả là đã đọc',
              onPressed: () {
                setState(() {
                  _notifications = _notifications
                      .map(
                        (n) => NotificationModel(
                          id: n.id,
                          title: n.title,
                          body: n.body,
                          createdAt: n.createdAt,
                          status: n.status,
                          isRead: true,
                        ),
                      )
                      .toList();
                });
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: _buildBodyState(),
    );
  }

  Widget _buildBodyState() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Hộp thư trống!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Các cập nhật và trạng thái đơn đặt lịch của bạn sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF7E84A2)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _notifications.length,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      physics: const BouncingScrollPhysics(),
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
                status: item.status,
                isRead: true,
              );
            });
          },
        );
      },
    );
  }
}
