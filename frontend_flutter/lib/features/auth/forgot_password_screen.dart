// lib/features/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/auth/forgot_password_form.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOtpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Khôi phục mật khẩu',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthService, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetOtpSent) {
              setState(() {
                _isOtpSent = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Mã OTP đã được gửi tới máy điện thoại của bạn!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is AuthPasswordResetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đổi mật khẩu thành công. Vui lòng đăng nhập lại bằng mật khẩu mới.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
            if (state is AuthPasswordResetEmailSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'Nếu email này đã được liên kết với tài khoản BrokerViet, chúng tôi đã gửi liên kết đặt lại mật khẩu. Vui lòng kiểm tra hộp thư đến và thư rác.',
                  ),
                ),
              );

              Navigator.pop(context);
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ForgotPasswordForm(
                formKey: _formKey,
                phoneController: _phoneController,
                emailController: _emailController,
                otpController: _otpController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                isOtpSent: _isOtpSent,
                isLoading: state is AuthLoading,
                onSubmit: (method) {
                  if (!_formKey.currentState!.validate()) return;

                  if (!_isOtpSent) {
                    if (method == RecoveryMethod.phone) {
                      context.read<AuthService>().add(
                        ForgotPasswordByPhoneRequested(
                          _phoneController.text.trim(),
                        ),
                      );
                    } else {
                      context.read<AuthService>().add(
                        ForgotPasswordByEmailRequested(
                          _emailController.text.trim(),
                        ),
                      );
                    }

                    return;
                  }

                  context.read<AuthService>().add(
                    ForgotPasswordPhoneConfirmed(
                      phone: _phoneController.text.trim(),
                      otpCode: _otpController.text.trim(),
                      newPassword: _passwordController.text,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
