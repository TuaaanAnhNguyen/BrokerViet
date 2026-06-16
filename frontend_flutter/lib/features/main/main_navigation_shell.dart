// lib/features/main/main_navigation_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth/auth_service.dart';
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

  final List<Widget> _customerTabs = const [
    ServiceMarketplaceScreen(),
    BookingHistoryScreen(),
    ChatListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // context.watch để cập nhật avatar khi đăng nhập thành công
    final authState = context.watch<AuthService>().state;

    String avatar = 'assets/default_profile.png';
    if (authState is AuthSuccess) {
      avatar = authState.avatarPath;
    }

    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    // Sử dụng BlocListener bọc ngoài cùng Scaffold để xử lý luồng bay của giao diện
    return BlocListener<AuthService, AuthState>(
      listener: (context, state) {
        // Nếu trạng thái bị chuyển về Initial hoặc thất bại (tức là đã SignOut hoặc mất session)
        if (state is AuthInitial || state is AuthFailure) {
          // Ép toàn bộ Navigator xóa sạch các page cũ đang đè và reset trạng thái giao diện về ban đầu
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

        body: IndexedStack(index: _currentIndex, children: _customerTabs),

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
            items: const [
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
            ],
          ),
        ),
      ),
    );
  }
}
