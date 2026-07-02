// lib/features/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isOtpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      final phoneInput = _phoneController.text.trim();

      if (!_isOtpSent) {
        context.read<AuthService>().add(ForgotPasswordRequested(phoneInput));
      } else {
        context.read<AuthService>().add(
          ForgotPasswordConfirmed(
            phoneInput,
            _otpController.text.trim(),
            _passwordController.text.trim(),
          ),
        );
      }
    }
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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isOtpSent
                          ? 'Nhập mã số OTP gồm 6 chữ số và thiết lập chuỗi mật khẩu bảo mật mới.'
                          : 'Nhập số điện thoại đã đăng ký tài khoản để hệ thống gửi mã xác thực OTP khôi phục.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Số điện thoại',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: !_isOtpSent,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (!RegExp(r'^[0-9]{9,11}$').hasMatch(
                          value.trim().replaceAll(RegExp(r'\s+'), ''),
                        )) {
                          return 'Định dạng số điện thoại chưa đúng';
                        }
                        return null;
                      },
                    ),
                    if (_isOtpSent) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _otpController,
                        labelText: 'Mã xác thực OTP',
                        prefixIcon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Vui lòng nhập mã OTP'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Mật khẩu mới',
                        prefixIcon: Icons.lock_outlined,
                        isPasswordField: true,
                        validator: (value) => value == null || value.length < 6
                            ? 'Mật khẩu mới phải từ 6 ký tự trở lên'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _submitRequest,
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
                          _isOtpSent ? 'Xác nhận đổi mật khẩu' : 'Gửi mã OTP',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
