// lib/feature/profile/account_setting.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/avatar_builder.dart';
import '../../services/profile/profile_service.dart';
import '../../models/profile_model.dart';

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color outlineVariant = Color(0xFFC3C6D7);

    // Ensure state context initializes clean data frames right at boot up
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
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
                // Header Profile Segment featuring buildAvatar widget
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

                // Button shortcut to edit basic standard user row values
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
                      onPressed: () => _showEditProfileForm(context, profile!),
                    ),
                  ),

                // Section 1: Security Parameters
                _buildSectionHeader('Bảo mật tài khoản'),
                _buildSettingTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Thay đổi mật khẩu',
                  subtitle: 'Cập nhật mật khẩu định kỳ để bảo vệ tài khoản',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildSettingTile(
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

                // Section 2: Linked Credentials
                _buildSectionHeader('Thông tin liên kết'),
                _buildSettingTile(
                  icon: Icons.email_outlined,
                  title: 'Thay đổi địa chỉ Email',
                  subtitle: emailDisplay,
                  onTap: () => _showChangeEmailDialog(context),
                ),
                _buildSettingTile(
                  icon: Icons.phone_android_rounded,
                  title: 'Thay đổi số điện thoại',
                  subtitle: phoneDisplay,
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                // 💡 Section 3: PROVIDER-ONLY BUSINESS METADATA (Role Whitelist Safeguard)
                if (isProvider && profile != null) ...[
                  _buildSectionHeader('Thông tin vận hành (Chỉ Đối Tác)'),
                  _buildSettingTile(
                    icon: Icons.storefront_outlined,
                    title: 'Cấu hình khung giờ hoạt động',
                    subtitle:
                        'Mở cửa: ${profile.openingHour ?? "Chưa thiết lập"} • Đóng cửa: ${profile.closingHour ?? "Chưa thiết lập"}',
                    onTap: () => _showEditProfileForm(context, profile!),
                  ),
                  _buildSettingTile(
                    icon: Icons.map_outlined,
                    title: 'Địa chỉ & Tọa độ bản đồ',
                    subtitle:
                        profile.locationText ??
                        profile.address ??
                        'Chưa xác định vị trí vệ tinh',
                    onTap: () => _showEditProfileForm(context, profile!),
                  ),
                  _buildSettingTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Tài khoản ngân hàng nhận Payout',
                    subtitle: profile.payoutAccountNumber != null
                        ? '[${profile.payoutBankCode ?? "Ngân hàng"}] ${profile.payoutAccountNumber}'
                        : 'Chưa cấu hình tài khoản nhận doanh thu',
                    onTap: () => _showEditProfileForm(context, profile!),
                  ),
                  const SizedBox(height: 16),
                ],

                // Section 4: Privacy & Preferences
                _buildSectionHeader('Quyền riêng tư & Thông báo'),
                _buildSettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Thông báo ứng dụng',
                  subtitle: 'Nhận cập nhật về tiến độ sửa chữa & tin nhắn',
                  trailing: Switch(
                    value: true,
                    activeThumbColor: primaryColor,
                    onChanged: (bool value) {},
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.g_translate_rounded,
                  title: 'Ngôn ngữ hiển thị',
                  subtitle: 'Tiếng Việt',
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                // Section 5: Danger Zone Actions
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
                    onTap: () => _showDeleteAccountPrompt(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing:
              trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFFC3C6D7),
              ),
          onTap: trailing == null ? onTap : null,
        ),
      ),
    );
  }

  // 💡 Smart Multi-Field Dynamic Form Interface Window Configuration Helper
  void _showEditProfileForm(BuildContext context, ProfileModel currentProfile) {
    final formKey = GlobalKey<FormState>();

    // Core parameters mapping
    String updatedName = currentProfile.username;
    String updatedBio = currentProfile.bio ?? '';
    String updatedAddress = currentProfile.address ?? '';

    // Provider specific local controllers initialization variables
    String updatedOpen = currentProfile.openingHour ?? '';
    String updatedClose = currentProfile.closingHour ?? '';
    String updatedLocText = currentProfile.locationText ?? '';
    String updatedBankCode = currentProfile.payoutBankCode ?? '';
    String updatedBankAcc = currentProfile.payoutAccountNumber ?? '';

    final bool isProvider = currentProfile.role?.toUpperCase() == 'PROVIDER';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cập nhật hồ sơ thông tin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 16),

                // Generic elements editable by anyone
                _buildFormLabel('Tên hiển thị'),
                _buildDialogTextField(
                  hint: 'Nhập tên mới',
                  initialValue: updatedName,
                  onChanged: (val) => updatedName = val,
                ),
                _buildFormLabel('Giới thiệu ngắn (Bio)'),
                _buildDialogTextField(
                  hint: 'Nhập tiểu sử ngắn bản thân',
                  initialValue: updatedBio,
                  onChanged: (val) => updatedBio = val,
                ),
                _buildFormLabel('Địa chỉ thường trú'),
                _buildDialogTextField(
                  hint: 'Nhập địa chỉ của bạn',
                  initialValue: updatedAddress,
                  onChanged: (val) => updatedAddress = val,
                ),

                // Provider specific structural injection blocks
                if (isProvider) ...[
                  const Divider(height: 32),
                  const Text(
                    'Cấu hình kinh doanh (Provider)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004AC6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Giờ mở cửa'),
                            _buildDialogTextField(
                              hint: '08:00:00',
                              initialValue: updatedOpen,
                              onChanged: (val) => updatedOpen = val,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Giờ đóng cửa'),
                            _buildDialogTextField(
                              hint: '22:00:00',
                              initialValue: updatedClose,
                              onChanged: (val) => updatedClose = val,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildFormLabel('Tên hiển thị vị trí định vị'),
                  _buildDialogTextField(
                    hint: 'Tòa nhà BrokerViet, Quận 1',
                    initialValue: updatedLocText,
                    onChanged: (val) => updatedLocText = val,
                  ),
                  _buildFormLabel('Mã ngân hàng (Swift/Bank Code)'),
                  _buildDialogTextField(
                    hint: 'VCB / TCB / MB',
                    initialValue: updatedBankCode,
                    onChanged: (val) => updatedBankCode = val,
                  ),
                  _buildFormLabel('Số tài khoản nhận Payout'),
                  _buildDialogTextField(
                    hint: '01234567890',
                    initialValue: updatedBankAcc,
                    onChanged: (val) => updatedBankAcc = val,
                  ),
                ],
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(modalContext),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final compiledModelUpdate = currentProfile.copyWith(
                            username: updatedName,
                            bio: updatedBio,
                            address: updatedAddress,
                            openingHour: updatedOpen.isNotEmpty
                                ? updatedOpen
                                : null,
                            closingHour: updatedClose.isNotEmpty
                                ? updatedClose
                                : null,
                            locationText: updatedLocText.isNotEmpty
                                ? updatedLocText
                                : null,
                            payoutBankCode: updatedBankCode.isNotEmpty
                                ? updatedBankCode
                                : null,
                            payoutAccountNumber: updatedBankAcc.isNotEmpty
                                ? updatedBankAcc
                                : null,
                          );
                          // Dispatch the data model to the BLoC service context cleanly
                          context.read<ProfileService>().add(
                            UpdateProfileRequested(compiledModelUpdate),
                          );
                          Navigator.pop(modalContext);
                        }
                      },
                      child: const Text(
                        'Lưu thay đổi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    String newPassword = '';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(hint: 'Mật khẩu hiện tại', obscure: true),
            const SizedBox(height: 10),
            _buildDialogTextField(
              hint: 'Mật khẩu mới',
              obscure: true,
              onChanged: (val) => newPassword = val,
            ),
            const SizedBox(height: 10),
            _buildDialogTextField(hint: 'Xác nhận mật khẩu mới', obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPassword.isNotEmpty) {
                context.read<ProfileService>().add(
                  UpdatePasswordRequested(newPassword: newPassword),
                );
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AC6),
            ),
            child: const Text(
              'Cập nhật',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    String destinationMail = '';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Thay đổi Email',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(
              hint: 'Địa chỉ Email mới',
              obscure: false,
              onChanged: (val) => destinationMail = val,
            ),
            const SizedBox(height: 10),
            const Text(
              'Hệ thống sẽ gửi một liên kết xác nhận mã OTP về hòm thư này để hoàn tất thay đổi.',
              style: TextStyle(color: Colors.black45, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogContext.mounted && destinationMail.contains('@')) {
                context.read<ProfileService>().add(
                  UpdateEmailRequested(destinationMail),
                );
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AC6),
            ),
            child: const Text('Gửi mã', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Xóa tài khoản vĩnh viễn?',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Hành động này không thể hoàn tác. Toàn bộ thông tin đặt lịch dịch vụ, ví liên kết và lịch sử trò chuyện của bạn sẽ bị gỡ sạch khỏi hệ thống BrokerViet.',
          style: TextStyle(fontSize: 13, height: 1.3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy bỏ'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileService>().add(DeleteAccountRequested());
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Exit configuration panel settings loop
            },
            child: Text(
              'Tôi xác nhận xóa',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required String hint,
    bool obscure = false,
    String? initialValue,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
