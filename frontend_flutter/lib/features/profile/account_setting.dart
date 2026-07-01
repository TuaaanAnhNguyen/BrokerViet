// lib/feature/profile/account_setting.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/avatar_builder.dart';
import '../../services/profile/profile_service.dart';
import '../../models/profile_model.dart';
import '../../widgets/profile/account_setting_tile.dart';
import '../../widgets/profile/edit_profile_sheet.dart';

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color outlineVariant = Color(0xFFC3C6D7);

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
          'Thiết lập tài khoản',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: BlocListener<ProfileService, ProfileState>(
        listener: (context, state) {
          if (state is ProfileActionSuccess) {
            _showSnackBar(context, state.successMessage, Colors.green);
          } else if (state is ProfileFailure) {
            _showSnackBar(context, state.errorMessage, Colors.red);
          }
        },
        child: BlocBuilder<ProfileService, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            ProfileModel? profile;
            String avatarPath = 'assets/default_profile.png';
            String nameDisplay = 'Người dùng';
            String tierDisplay = 'CUSTOMER';
            String emailDisplay = 'Chưa cập nhật email';
            String phoneDisplay = 'Chưa xác thực';

            if (state is ProfileLoadSuccess) {
              profile = state.profile;
              avatarPath = profile.avatarUrl ?? 'assets/default_profile.png';
              nameDisplay = profile.username;
              tierDisplay = profile.role?.toUpperCase() == 'PROVIDER'
                  ? 'NHÀ CUNG CẤP'
                  : 'KHÁCH HÀNG';
              emailDisplay = profile.email?.isNotEmpty == true
                  ? profile.email!
                  : 'Chưa cập nhật email';
              phoneDisplay = profile.phone?.isNotEmpty == true
                  ? profile.phone!
                  : 'Chưa xác thực';
            }

            final bool isProvider = profile?.role?.toUpperCase() == 'PROVIDER';

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // Header Profile Segment
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      buildAvatar(avatarPath),
                      const SizedBox(height: 12),
                      Text(
                        nameDisplay,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tierDisplay,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                if (profile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Chỉnh sửa thông tin cá nhân',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      onPressed: () => _openEditSheet(context, profile!),
                    ),
                  ),

                // Section 1: Security
                _buildSectionHeader('Bảo mật tài khoản'),
                AccountSettingTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Thay đổi mật khẩu',
                  subtitle: 'Cập nhật mật khẩu định kỳ để bảo vệ tài khoản',
                  onTap: () {}, // Add target dialog method execution here
                ),
                AccountSettingTile(
                  icon: Icons.phonelink_lock_rounded,
                  title: 'Xác thực 2 lớp (2FA)',
                  subtitle: 'Bảo vệ bổ sung bằng mã OTP qua số điện thoại',
                  trailing: Switch(
                    value: true,
                    activeThumbColor: primaryColor,
                    onChanged: (bool value) {},
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Links
                _buildSectionHeader('Thông tin liên kết'),
                AccountSettingTile(
                  icon: Icons.email_outlined,
                  title: 'Thay đổi địa chỉ Email',
                  subtitle: emailDisplay,
                  onTap: () {},
                ),
                AccountSettingTile(
                  icon: Icons.phone_android_rounded,
                  title: 'Thay đổi số điện thoại',
                  subtitle: phoneDisplay,
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                // Section 3: Provider Operational Data
                if (isProvider && profile != null) ...[
                  _buildSectionHeader('Thông tin vận hành (Chỉ Đối Tác)'),
                  AccountSettingTile(
                    icon: Icons.storefront_outlined,
                    title: 'Cấu hình khung giờ hoạt động',
                    subtitle:
                        'Mở cửa: ${profile.openingHour ?? "Chưa thiết lập"} • Đóng cửa: ${profile.closingHour ?? "Chưa thiết lập"}',
                    onTap: () => _openEditSheet(context, profile!),
                  ),
                  AccountSettingTile(
                    icon: Icons.map_outlined,
                    title: 'Địa chỉ & Tọa độ bản đồ',
                    subtitle:
                        profile.locationText ??
                        profile.address ??
                        'Chưa xác định vị trí vệ tinh',
                    onTap: () => _openEditSheet(context, profile!),
                  ),
                  AccountSettingTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Tài khoản ngân hàng nhận Payout',
                    subtitle: profile.payoutAccountNumber != null
                        ? '[${profile.payoutBankCode ?? "Ngân hàng"}] ${profile.payoutAccountNumber}'
                        : 'Chưa cấu hình tài khoản nhận doanh thu',
                    onTap: () => _openEditSheet(context, profile!),
                  ),
                  const SizedBox(height: 16),
                ],

                // Section 4: Privacy
                _buildSectionHeader('Quyền riêng tư & Thông báo'),
                AccountSettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Thông báo ứng dụng',
                  subtitle: 'Nhận cập nhật về tiến độ sửa chữa & tin nhắn',
                  trailing: Switch(
                    value: true,
                    activeThumbColor: primaryColor,
                    onChanged: (bool value) {},
                  ),
                ),
                AccountSettingTile(
                  icon: Icons.g_translate_rounded,
                  title: 'Ngôn ngữ hiển thị',
                  subtitle: 'Tiếng Việt',
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                // Section 5: Danger Zone
                _buildSectionHeader('Vùng nguy hiểm'),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red.shade700,
                      size: 22,
                    ),
                    title: Text(
                      'Yêu cầu xóa tài khoản',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'Xóa vĩnh viễn dữ liệu profile và lịch sử giao dịch',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFFC3C6D7),
                    ),
                    onTap: () {},
                  ),
                ),
              ],
            );
          },
        ),
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
      builder: (modalContext) => EditProfileSheet(currentProfile: profile),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: bgColor));
  }
}
