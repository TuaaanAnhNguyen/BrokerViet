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
      if (!_isOtpSent) {
        context.read<AuthService>().add(
          PasswordResetRequested(_phoneController.text.trim()),
        );
      } else {
        context.read<AuthService>().add(
          PasswordResetConfirmed(
            _phoneController.text.trim(),
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
          style: TextStyle(color: Colors.black87),
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
                  content: Text('Mã OTP đã được gửi!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is AuthPasswordResetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đổi mật khẩu thành công. Vui lòng đăng nhập lại.',
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
                          ? 'Nhập mã OTP được gửi tới số điện thoại và đặt mật khẩu mới.'
                          : 'Nhập số điện thoại của bạn để nhận mã xác thực OTP khôi phục.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Số điện thoại',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: !_isOtpSent,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vui lòng nhập số điện thoại'
                          : null,
                    ),
                    if (_isOtpSent) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _otpController,
                        labelText: 'Mã xác thực OTP',
                        prefixIcon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
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
                            ? 'Mật khẩu mới phải từ 6 ký tự'
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
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isOtpSent ? 'Xác nhận đổi mật khẩu' : 'Gửi mã OTP',
                          style: const TextStyle(
                            fontSize: 16,
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
