// lib/features/main/notification_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/notification_tile.dart';
import '../../models/notification_model.dart';
import '../../services/notification/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final List<String> _tabs = ['Tất cả', 'Chưa đọc'];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);

    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.streamNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FF),
            body: _LoadingState(),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FF),
            body: Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}')),
          );
        }

        final allNotifications = snapshot.data ?? [];
        final unreadNotifications = allNotifications
            .where((n) => !n.isRead)
            .toList();
        final hasUnread = unreadNotifications.isNotEmpty;

        return DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FF),
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
              centerTitle: false,
              actions: [
                if (hasUnread)
                  IconButton(
                    icon: const Icon(Icons.done_all, color: primaryColor),
                    tooltip: 'Đánh dấu tất cả là đã đọc',
                    onPressed: () => _notificationService.markAllAsRead(),
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFC3C6D7).withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: TabBar(
                    labelColor: primaryColor,
                    unselectedLabelColor: const Color(0xFF434655),
                    indicatorColor: primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                NotificationList(
                  notifications: allNotifications,
                  notificationService: _notificationService,
                ),
                NotificationList(
                  notifications: unreadNotifications,
                  notificationService: _notificationService,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final NotificationService notificationService;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      itemCount: notifications.length,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () {
            if (!notification.isRead) {
              notificationService.markAsRead(notification.notificationId);
            }
          },
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7E84A2),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
