// lib/features/main/main_navigation_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🟢 Added package import

import '../../services/auth/auth_service.dart'; // 🟢 Added AuthService import
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
    // 🟢 Watch the active authentication state from your global Bloc
    final authState = context.watch<AuthService>().state;

    // Fallback default avatar path in case state isn't AuthSuccess
    String avatar = 'assets/default_avatar.png';

    // 🟢 Extract the correct image string if a user session is active
    if (authState is AuthSuccess) {
      avatar = authState.avatarPath;
    }

    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BrokerViet',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: darkText),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
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
                    MaterialPageRoute(builder: (context) => const ProfileMenuScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFEFF4FF),
                  backgroundImage: AssetImage(avatar), // 🟢 Uses the synced avatar variable!
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: outlineVariant.withOpacity(0.5), height: 1),
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _customerTabs,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.4), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: primaryColor,
          unselectedItemColor: bodyText,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
    );
  }
}