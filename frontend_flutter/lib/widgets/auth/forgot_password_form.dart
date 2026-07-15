// lib/widgets/auth/forgot_password_form.dart

import 'package:flutter/material.dart';
import 'phone_input_fields.dart';
import 'reset_password_fields.dart';
import '../custom_text_field.dart';

enum RecoveryMethod { phone, email }

class ForgotPasswordForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController otpController;
  final TextEditingController passwordController;
  final bool isOtpSent;
  final bool isLoading;
  final Function(RecoveryMethod method) onSubmit;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.emailController,
    required this.otpController,
    required this.passwordController,
    required this.isOtpSent,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  RecoveryMethod _selectedMethod = RecoveryMethod.phone;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.isOtpSent) ...[
            const Text(
              'Chọn phương thức khôi phục mật khẩu:',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Số điện thoại')),
                    selected: _selectedMethod == RecoveryMethod.phone,
                    selectedColor: const Color(
                      0xFF004AC6,
                    ).withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _selectedMethod == RecoveryMethod.phone
                          ? const Color(0xFF004AC6)
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected)
                        setState(() => _selectedMethod = RecoveryMethod.phone);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Email')),
                    selected: _selectedMethod == RecoveryMethod.email,
                    selectedColor: const Color(
                      0xFF004AC6,
                    ).withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _selectedMethod == RecoveryMethod.email
                          ? const Color(0xFF004AC6)
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected)
                        setState(() => _selectedMethod = RecoveryMethod.email);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          Text(
            widget.isOtpSent
                ? 'Nhập mã OTP xác thực và thiết lập mật khẩu bảo mật mới.'
                : _selectedMethod == RecoveryMethod.phone
                ? 'Nhập số điện thoại đã đăng ký để hệ thống gửi mã OTP SMS.'
                : 'Nhập email đã liên kết với tài khoản để nhận mã OTP qua hòm thư.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          if (_selectedMethod == RecoveryMethod.phone)
            PhoneInputFields(
              phoneController: widget.phoneController,
              isEnabled: !widget.isOtpSent,
            )
          else
            CustomTextField(
              controller: widget.emailController,
              labelText: 'Địa chỉ Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !widget.isOtpSent,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value.trim())) {
                  return 'Định dạng email không hợp lệ';
                }
                return null;
              },
            ),

          if (widget.isOtpSent)
            ResetPasswordFields(
              otpController: widget.otpController,
              passwordController: widget.passwordController,
            ),

          const SizedBox(height: 24),

          if (widget.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () => widget.onSubmit(_selectedMethod),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AC6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.isOtpSent ? 'Xác nhận đổi mật khẩu' : 'Gửi mã OTP',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
