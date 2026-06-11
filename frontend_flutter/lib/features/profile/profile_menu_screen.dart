// lib/features/profile/profile_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth/auth_service.dart';
import '../../widgets/avatar_builder.dart';
import '../auth/login_screen.dart';
import 'profile_screen.dart';
import 'account_setting.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          content: Row(
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(width: 24),
              Text(
                'Đang đăng xuất...',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthService>().state;

    String dispName = 'Khách';
    String subTitleInfo = 'Thành viên';
    String avatar = 'assets/default_profile.png';

    if (authState is AuthSuccess) {
      dispName = authState.name;
      subTitleInfo = authState.memberTier;
      avatar = authState.avatarPath;
    }

    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return BlocListener<AuthService, AuthState>(
      listenWhen: (previous, current) => current is AuthInitial,
      listener: (context, state) {
        Navigator.of(context, rootNavigator: true).pop();

        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 350),
          ),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: surfaceColor,
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
          titleSpacing: 0,
          title: const Text(
            'Tài khoản',
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: outlineVariant.withOpacity(0.5), height: 1),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  buildAvatar(avatar, radius: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dispName,
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subTitleInfo,
                          style: const TextStyle(color: bodyText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: bodyText,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildMenuSectionTitle('Cài đặt cá nhân'),
            _buildMenuTile(
              icon: Icons.person_outline_rounded,
              title: 'Thông tin cá nhân',
              subtitle: 'Cập nhật căn cước, số điện thoại, email',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: 'Thiết lập tài khoản',
              subtitle: 'Thay đổi tùy chọn bảo mật ứng dụng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildMenuSectionTitle('Hệ thống'),
            _buildMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'Về BrokerViet',
              subtitle: 'Phiên bản hệ thống 1.0.2-Stable',
              onTap: () {},
            ),

            Container(
              decoration: const BoxDecoration(color: Colors.white),
              margin: const EdgeInsets.only(top: 16),
              child: ListTile(
                leading: Icon(Icons.logout_rounded, color: Colors.red.shade700),
                title: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      title: const Text('Đăng xuất'),
                      content: const Text(
                        'Bạn có chắc chắn muốn thoát khỏi phiên làm việc?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _showLoadingDialog(context);
                            context.read<AuthService>().add(LogoutRequested());
                          },
                          child: Text(
                            'Đăng xuất',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF7E84A2),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F3F6), width: 0.5),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF004AC6), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0B1C30),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF7E84A2), fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Color(0xFFC3C6D7),
        ),
        onTap: onTap,
      ),
    );
  }
}
