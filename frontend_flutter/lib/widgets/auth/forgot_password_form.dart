// lib/widgets/auth/forgot_password_form.dart

import 'package:flutter/material.dart';

import 'email_input_field.dart';
import 'phone_input_fields.dart';
import 'reset_password_fields.dart';

enum RecoveryMethod { phone, email }

class ForgotPasswordForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController otpController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final bool isOtpSent;
  final bool isLoading;

  final ValueChanged<RecoveryMethod> onSubmit;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.emailController,
    required this.otpController,
    required this.passwordController,
    required this.confirmPasswordController,
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
              'Chọn phương thức khôi phục mật khẩu',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Số điện thoại'),
                    selected: _selectedMethod == RecoveryMethod.phone,
                    onSelected: (_) {
                      setState(() {
                        _selectedMethod = RecoveryMethod.phone;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ChoiceChip(
                    label: const Text('Email'),
                    selected: _selectedMethod == RecoveryMethod.email,
                    onSelected: (_) {
                      setState(() {
                        _selectedMethod = RecoveryMethod.email;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],

          Text(
            widget.isOtpSent
                ? 'Nhập mã OTP và thiết lập mật khẩu mới.'
                : _selectedMethod == RecoveryMethod.phone
                ? 'Nhập số điện thoại đã đăng ký.'
                : 'Nhập email đã liên kết với tài khoản.',
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),

          const SizedBox(height: 24),

          if (_selectedMethod == RecoveryMethod.phone)
            PhoneInputFields(
              phoneController: widget.phoneController,
              isEnabled: !widget.isOtpSent,
            )
          else
            EmailInputField(
              emailController: widget.emailController,
              isEnabled: !widget.isOtpSent,
            ),

          if (widget.isOtpSent)
            // Phone
            ResetPasswordFields(
              otpController: widget.otpController,
              passwordController: widget.passwordController,
              confirmPasswordController: widget.confirmPasswordController,
              showOtp: true,
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
                widget.isOtpSent ? 'Xác nhận đổi mật khẩu' : 'Gửi yêu cầu',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
