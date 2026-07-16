// lib/widgets/auth/reset_password_fields.dart

import 'package:flutter/material.dart';
import '../custom_text_field.dart';

class ResetPasswordFields extends StatelessWidget {
  final TextEditingController? otpController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showOtp;

  const ResetPasswordFields({
    super.key,
    this.otpController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.showOtp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showOtp) ...[
          const SizedBox(height: 16),

          CustomTextField(
            controller: otpController!,
            labelText: 'Mã OTP',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã OTP';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          CustomTextField(
            controller: passwordController,
            labelText: 'Mật khẩu mới',
            prefixIcon: Icons.lock_outline,
            isPasswordField: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          CustomTextField(
            controller: confirmPasswordController,
            labelText: 'Xác nhận mật khẩu',
            prefixIcon: Icons.lock_outline,
            isPasswordField: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }

              if (value != passwordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }

              return null;
            },
          ),
        ],
      ],
    );
  }
}
