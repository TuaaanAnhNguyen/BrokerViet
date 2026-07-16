// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/profile_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/profile/profile_service.dart';

import '../../widgets/profile/profile_summary_card.dart';
import '../../widgets/profile/profile_info_section.dart';
import '../../widgets/profile/profile_contact_card.dart';
import '../../widgets/profile/profile_provider_card.dart';

import 'account_setting.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null && context.mounted) {
      context.read<AuthService>().add(UpdateAvatarRequested(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004AC6);
    const surfaceColor = Color(0xFFF8F9FF);
    const darkText = Color(0xFF0B1C30);
    const outlineVariant = Color(0xFFC3C6D7);

    context.read<ProfileService>().add(LoadProfileRequested());

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
          "Thông tin cá nhân",
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountSettingScreen()),
              ).then((_) {
                if (context.mounted) {
                  context.read<ProfileService>().add(LoadProfileRequested());
                }
              });
            },
            child: const Text(
              "Chỉnh sửa",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: outlineVariant.withValues(alpha: .5),
          ),
        ),
      ),
      body: BlocBuilder<ProfileService, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          ProfileModel? profile;

          String avatar = "assets/default_profile.png";
          String username = "Người dùng";
          String role = "KHÁCH HÀNG";
          String email = "Chưa cập nhật email";
          String phone = "Chưa liên kết số điện thoại";
          String address = "Chưa cung cấp địa chỉ";

          if (state is ProfileLoadSuccess) {
            profile = state.profile;

            avatar = profile.avatarUrl ?? avatar;
            username = profile.username;

            role = profile.role?.toUpperCase() == "PROVIDER"
                ? "NHÀ CUNG CẤP"
                : "KHÁCH HÀNG";

            email = profile.email?.isNotEmpty == true ? profile.email! : email;

            phone = profile.phone?.isNotEmpty == true ? profile.phone! : phone;

            address = profile.address?.isNotEmpty == true
                ? profile.address!
                : address;
          }

          final isProvider = profile?.role?.toUpperCase() == "PROVIDER";

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              context.read<ProfileService>().add(LoadProfileRequested());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                ProfileSummaryCard(
                  avatarPath: avatar,
                  username: username,
                  roleDisplay: role,
                  onAvatarTap: () => _pickAndUploadImage(context),
                ),

                ProfileInfoSection(
                  title: "Thông tin liên hệ",
                  children: [
                    ProfileContactCard(
                      phone: phone,
                      email: email,
                      address: address,
                    ),
                  ],
                ),

                if (profile?.bio != null && profile!.bio!.trim().isNotEmpty)
                  ProfileInfoSection(
                    title: "Giới thiệu",
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          profile.bio!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: darkText,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),

                if (isProvider && profile != null)
                  ProfileInfoSection(
                    title: "Thông tin nhà cung cấp",
                    children: [ProfileProviderCard(profile: profile)],
                  ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
