// lib/features/profile/profile_screen.dart
// the main profile screen that shows the user's information and a back button to go to the profile menu screen

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Trigger input state switches / update operations endpoints
            },
            child: const Text(
              'Chỉnh sửa',
              style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: outlineVariant.withOpacity(0.5), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Centered Dynamic Avatar Profile Section Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 46,
                        backgroundColor: Color(0xFFEFF4FF),
                        child: Text(
                          'N',
                          style: TextStyle(color: primaryColor, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nguyễn Văn A',
                    style: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tài khoản Đối tác/Khách hàng Liên kết',
                    style: TextStyle(color: bodyText, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Form Block 1: Contact Parameters Metadata
            _buildInfoCardGroup(
              title: 'Thông tin cơ bản',
              children: [
                _buildProfileDataRow('Họ và tên', 'Nguyễn Văn A'),
                _buildProfileDataRow('Mã sinh viên / ID', 'FPTU-9912'),
                _buildProfileDataRow('Ngày sinh', '01 / 01 / 2004'),
                _buildProfileDataRow('Giới tính', 'Nam'),
              ],
              outlineVariant: outlineVariant,
              darkText: darkText,
            ),
            const SizedBox(height: 16),

            // Profile Form Block 2: Communication Data Records
            _buildInfoCardGroup(
              title: 'Liên hệ & Xác thực',
              children: [
                _buildProfileDataRow('Số điện thoại', '0912 345 678'),
                _buildProfileDataRow('Địa chỉ Email', 'anv@fe.edu.vn'),
                _buildProfileDataRow('Địa chỉ lưu trú', 'Khu đô thị FPT City, Ngũ Hành Sơn, Đà Nẵng'),
                _buildProfileDataRow('Trạng thái xác minh', 'Đã liên kết Ví BrokerPay', isVerified: true),
              ],
              outlineVariant: outlineVariant,
              darkText: darkText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCardGroup({
    required String title,
    required List<Widget> children,
    required Color outlineVariant,
    required Color darkText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(color: darkText.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: outlineVariant.withOpacity(0.3)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileDataRow(String label, String value, {bool isVerified = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F6), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF7E84A2), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Color(0xFF0B1C30), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}