// lib/features/main/main_navigation_shell.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screens/provider/provider_bookings_screen.dart';
import '../../screens/provider/provider_dashboard_screen.dart';
import '../../screens/provider/provider_services_list_screen.dart';
import '../../screens/provider/voucher/voucher_list_screen.dart';
import '../../services/auth/auth_service.dart';
import '../../services/notification/notification_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/avatar_builder.dart';
import 'service_marketplace_screen.dart';
import '../booking/booking_history_screen.dart';
import '../chat/chat_list_screen.dart';
import './notification_screen.dart';
import '../profile/profile_menu_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<List<NotificationModel>>? _notificationSubscription;
  List<NotificationModel>? _lastNotifications;

  // 1. Define Customer Tabs
  final List<Widget> _customerTabs = [
    const ServiceMarketplaceScreen(),
    const BookingHistoryScreen(),
    const ChatListScreen(),
  ];

  // 2. Define Provider Tabs
  final List<Widget> _providerTabs = [
    const ProviderDashboardScreen(),
    // const ProviderBookingsScreen(),
    const ProviderServicesListScreen(),
    const VoucherListScreen(),
    const ChatListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _notificationSubscription = _notificationService
        .streamNotifications()
        .listen((notifications) {
          if (_lastNotifications != null) {
            final newNotifications = notifications
                .where(
                  (n) => !_lastNotifications!.any(
                    (old) => old.notificationId == n.notificationId,
                  ),
                )
                .toList();

            for (var notification in newNotifications) {
              if (!notification.isRead) {
                _showNewNotificationSnackBar(notification);
              }
            }
          }

          if (mounted) {
            setState(() {
              _lastNotifications = notifications;
            });
          }
        });
  }

  void _showNewNotificationSnackBar(NotificationModel notification) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              notification.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004AC6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'XEM',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildCustomerNavbarItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.storefront_outlined),
        activeIcon: Icon(Icons.storefront),
        label: 'Khám phá',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment),
        label: 'Đơn đã mua',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline_rounded),
        activeIcon: Icon(Icons.chat_bubble_rounded),
        label: 'Tin nhắn',
      ),
    ];
  }

  List<BottomNavigationBarItem> _buildProviderNavbarItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Tổng quan',
      ),
      // BottomNavigationBarItem(
      //   icon: Icon(Icons.calendar_month_outlined),
      //   activeIcon: Icon(Icons.calendar_month),
      //   label: 'Lịch hẹn',
      // ),
      BottomNavigationBarItem(
        icon: Icon(Icons.construction_outlined),
        activeIcon: Icon(Icons.construction),
        label: 'Dịch vụ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.confirmation_number_outlined),
        activeIcon: Icon(Icons.confirmation_number),
        label: 'Mã giảm giá',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline_rounded),
        activeIcon: Icon(Icons.chat_bubble_rounded),
        label: 'Tin nhắn',
      ),
    ];
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthService>().state;

    String avatar = 'assets/default_profile.png';
    String role = 'customer';

    if (authState is AuthSuccess) {
      avatar = authState.avatarPath;
      role = authState.role.toLowerCase().trim();
    }

    final bool isProvider = role == 'provider';
    final List<Widget> activeTabs = isProvider ? _providerTabs : _customerTabs;

    if (_currentIndex >= activeTabs.length) {
      _currentIndex = 0;
    }

    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return BlocListener<AuthService, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial || state is AuthFailure) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'BrokerViet',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.streamNotifications(),
              builder: (context, snapshot) {
                final unreadCount =
                    snapshot.data?.where((n) => !n.isRead).length ?? 0;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: darkText,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8.0),
              child: Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileMenuScreen(),
                      ),
                    );
                  },
                  child: buildAvatar(avatar, radius: 16),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: outlineVariant.withValues(alpha: 0.5),
              height: 1,
            ),
          ),
        ),

        body: IndexedStack(index: _currentIndex, children: activeTabs),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: outlineVariant.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: bodyText,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: isProvider
                ? _buildProviderNavbarItems()
                : _buildCustomerNavbarItems(),
          ),
        ),
      ),
    );
  }
}
