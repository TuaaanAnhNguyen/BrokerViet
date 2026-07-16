// lib/feature/profile/account_setting.dart
// actual screen for profile editing

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/profile_model.dart';
import '../../services/profile/profile_service.dart';

import '../../widgets/profile/setting/profile_header.dart';
import '../../widgets/profile/setting/profile_edit_button.dart';
import '../../widgets/profile/setting/profile_security_section.dart';
import '../../widgets/profile/setting/profile_contact_section.dart';
import '../../widgets/profile/setting/profile_address_section.dart';
import '../../widgets/profile/setting/profile_provider_section.dart';
import '../../widgets/profile/setting/profile_danger_section.dart';

import '../../widgets/profile/setting/edit_profile_sheet.dart';
import '../../widgets/profile/setting/change_email_sheet.dart';
import '../../widgets/profile/setting/change_password_sheet.dart';

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({super.key});

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
            color: primaryColor,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "Thiết lập tài khoản",
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: outlineVariant.withValues(alpha: .5),
          ),
        ),
      ),

      body: BlocListener<ProfileService, ProfileState>(
        listener: (context, state) {
          if (state is ProfileActionSuccess) {
            _showSnackBar(context, state.successMessage, Colors.green);
          }

          if (state is ProfileFailure) {
            _showSnackBar(context, state.errorMessage, Colors.red);
          }
        },

        child: BlocBuilder<ProfileService, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            ProfileModel? profile;

            String avatar = "assets/default_profile.png";
            String username = "Người dùng";
            String role = "CUSTOMER";
            String email = "Chưa cập nhật email";
            String phone = "Chưa xác thực";

            if (state is ProfileLoadSuccess) {
              profile = state.profile;

              avatar = profile.avatarUrl ?? avatar;
              username = profile.username;

              role = profile.role?.toUpperCase() == "PROVIDER"
                  ? "NHÀ CUNG CẤP"
                  : "KHÁCH HÀNG";

              email = profile.email?.isNotEmpty == true
                  ? profile.email!
                  : email;

              phone = profile.phone?.isNotEmpty == true
                  ? profile.phone!
                  : phone;
            }

            final isProvider = profile?.role?.toUpperCase() == "PROVIDER";

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),

              children: [
                ProfileHeader(
                  avatarPath: avatar,
                  username: username,
                  roleDisplay: role,
                ),

                if (profile != null) ProfileEditButton(onPressed: () => ()),

                if (profile != null)
                  ProfileSecuritySection(
                    onChangePassword: () => _openChangePasswordSheet(context),
                  ),

                if (profile != null)
                  ProfileContactSection(
                    email: email,
                    phone: phone,
                    onChangeEmail: () =>
                        _openChangeEmailSheet(context, profile!.email ?? ''),
                  ),

                if (profile != null)
                  ProfileAddressSection(
                    profile: profile,
                    onEdit: () => _openEditSheet(context, profile!),
                  ),

                if (isProvider && profile != null)
                  ProfileProviderSection(
                    profile: profile,
                    onEdit: () => _openEditSheet(context, profile!),
                  ),

                ProfileDangerSection(onDelete: () => _confirmDelete(context)),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xóa tài khoản"),

        content: const Text("Hành động này không thể hoàn tác."),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              context.read<ProfileService>().add(DeleteAccountRequested());

              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context, ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditProfileSheet(currentProfile: profile),
    );
  }

  void _openChangeEmailSheet(BuildContext context, String currentEmail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeEmailSheet(currentEmail: currentEmail),
    );
  }

  void _openChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
