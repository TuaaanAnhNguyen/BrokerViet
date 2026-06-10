import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/avatar_builder.dart'; // ◄ 1. Import your avatar widget file
import '../../services/auth/auth_service.dart';  // ◄ Make sure to import your AuthService/State file path

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({super.key});

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
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Thiết lập tài khoản',
          style: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: outlineVariant.withValues(alpha: 0.5), height: 1),
        ),
      ),
      // 2. Wrap the body with a BlocBuilder to extract the current user data
      body: BlocBuilder<AuthService, AuthState>(
        builder: (context, state) {
          String avatarPath = 'assets/default_profile.png';
          String emailDisplay = 'chưa cập nhật email';
          String phoneDisplay = 'Chưa xác thực';

          if (state is AuthSuccess) {
            avatarPath = state.avatarPath;
            emailDisplay = state.email.isNotEmpty ? state.email : 'Chưa cập nhật email';
            // If phone isn't tracked in AuthSuccess, you can format your display string dynamically
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // 3. Header Profile Segment featuring your buildAvatar widget
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    buildAvatar(avatarPath), // ◄ 4. Injected your widget here dynamically!
                    const SizedBox(height: 12),
                    if (state is AuthSuccess) ...[
                      Text(
                        state.name,
                        style: const TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.memberTier,
                        style: const TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),

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

              // Section 2: Linked Credentials (Using real BLoC state)
              _buildSectionHeader('Thông tin liên kết'),
              _buildSettingTile(
                icon: Icons.email_outlined,
                title: 'Thay đổi địa chỉ Email',
                subtitle: emailDisplay, // ◄ Render true active email state dynamically
                onTap: () => _showChangeEmailDialog(context),
              ),
              _buildSettingTile(
                icon: Icons.phone_android_rounded,
                title: 'Thay đổi số điện thoại',
                subtitle: 'Đã xác thực bảo mật',
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // Section 3: Privacy & Preferences
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

              // Section 4: Danger Zone Actions
              _buildSectionHeader('Vùng nguy hiểm'),
              Container(
                color: Colors.white,
                child: ListTile(
                  leading: Icon(Icons.delete_forever_rounded, color: Colors.red.shade700, size: 22),
                  title: Text(
                    'Yêu cầu xóa tài khoản',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: const Text('Xóa vĩnh viễn dữ liệu profile và lịch sử giao dịch', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC3C6D7)),
                  onTap: () => _showDeleteAccountPrompt(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Keep your existing _buildSectionHeader, _buildSettingTile, and _show dialog helpers below unchanged...
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F6), width: 0.5)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF004AC6), size: 22),
        title: Text(title, style: const TextStyle(color: Color(0xFF0B1C30), fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF7E84A2), fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC3C6D7)),
        onTap: trailing == null ? onTap : null,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(hint: 'Mật khẩu hiện tại', obscure: true),
            const SizedBox(height: 10),
            _buildDialogTextField(hint: 'Mật khẩu mới', obscure: true),
            const SizedBox(height: 10),
            _buildDialogTextField(hint: 'Xác nhận mật khẩu mới', obscure: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AC6)),
            child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thay đổi Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(hint: 'Địa chỉ Email mới', obscure: false),
            const SizedBox(height: 10),
            const Text(
              'Hệ thống sẽ gửi một liên kết xác nhận mã OTP về hòm thư này để hoàn tất thay đổi.',
              style: TextStyle(color: Colors.black45, fontSize: 11),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AC6)),
            child: const Text('Gửi mã', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa tài khoản vĩnh viễn?', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
        content: const Text(
          'Hành động này không thể hoàn tác. Toàn bộ thông tin đặt lịch dịch vụ, ví liên kết và lịch sử trò chuyện của bạn sẽ bị gỡ sạch khỏi hệ thống BrokerViet.',
          style: TextStyle(fontSize: 13, height: 1.3),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy bỏ')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tôi xác nhận xóa', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({required String hint, required bool obscure}) {
    return TextFormField(
      obscureText: obscure,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}