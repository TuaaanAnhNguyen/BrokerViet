// lib/features/profile/profile_screen.dart
// the main profile screen that shows the user's information and a back button to go to the profile menu screen

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth/auth_service.dart';
import '../../widgets/avatar_builder.dart'; // ◄ Import your shared widget helper

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Optimize image size
    );

    if (image != null && context.mounted) {
      context.read<AuthService>().add(UpdateAvatarRequested(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Scaffold(
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
          'Thông tin cá nhân',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Trigger input state switches / update operations endpoints
            },
            child: const Text(
              'Chỉnh sửa',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      // Wrapped with BlocBuilder to consume live authenticated data snapshots safely
      body: BlocBuilder<AuthService, AuthState>(
        builder: (context, state) {
          String name = 'Khách';
          String email = 'Chưa cập nhật email';
          String tier = 'Thành viên';
          String avatarPath = 'assets/default_profile.png';

          if (state is AuthSuccess) {
            name = state.name;
            email = state.email.isNotEmpty
                ? state.email
                : 'Chưa cập nhật email';
            tier = state.memberTier;
            avatarPath = state.avatarPath;
          }

          return SingleChildScrollView(
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
                    border: Border.all(
                      color: outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _pickAndUploadImage(context),
                        child: Stack(
                          children: [
                            // ◄ Replaced generic character text circle with your reactive widget
                            buildAvatar(avatarPath, radius: 46),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier,
                        style: const TextStyle(
                          color: Color(0xFF434655),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Form Block 1: Contact Parameters Metadata
                _buildInfoCardGroup(
                  title: 'Thông tin cơ bản',
                  children: [
                    _buildProfileDataRow('Họ và tên', name),
                    _buildProfileDataRow(
                      'Mã thành viên',
                      state is AuthSuccess
                          ? 'ID: ${state.uid.substring(0, 8).toUpperCase()}'
                          : '---',
                    ),
                    _buildProfileDataRow('Ngày sinh', 'Chưa cập nhật'),
                    _buildProfileDataRow('Giới tính', 'Chưa cập nhật'),
                  ],
                  outlineVariant: outlineVariant,
                  darkText: darkText,
                ),
                const SizedBox(height: 16),

                // Profile Form Block 2: Communication Data Records
                _buildInfoCardGroup(
                  title: 'Liên hệ & Xác thực',
                  children: [
                    _buildProfileDataRow('Số điện thoại', 'Đã liên kết'),
                    _buildProfileDataRow('Địa chỉ Email', email),
                    _buildProfileDataRow('Địa chỉ', 'Chưa cung cấp'),
                    _buildProfileDataRow(
                      'Trạng thái',
                      'Đã xác thực tài khoản BrokerViet',
                      isVerified: true,
                    ),
                  ],
                  outlineVariant: outlineVariant,
                  darkText: darkText,
                ),
              ],
            ),
          );
        },
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
            style: TextStyle(
              color: darkText.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileDataRow(
    String label,
    String value, {
    bool isVerified = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F3F6), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7E84A2),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0B1C30),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
