// lib/widgets/auth/reset_password_fields.dart

import 'package:flutter/material.dart';
import '../custom_text_field.dart';

class ResetPasswordFields extends StatelessWidget {
  final TextEditingController otpController;
  final TextEditingController passwordController;

  const ResetPasswordFields({
    super.key,
    required this.otpController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        CustomTextField(
          controller: otpController,
          labelText: 'Mã xác thực OTP',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Vui lòng nhập mã OTP'
              : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          labelText: 'Mật khẩu mới',
          prefixIcon: Icons.lock_outlined,
          isPasswordField: true,
          validator: (value) => value == null || value.length < 6
              ? 'Mật khẩu mới phải từ 6 ký tự trở lên'
              : null,
        ),
      ],
    );
  }
}
