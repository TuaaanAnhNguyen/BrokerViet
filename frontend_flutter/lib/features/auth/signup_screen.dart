// lib/features/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tạo tài khoản'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tham gia BrokerViet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: _usernameController,
                    labelText: 'Tên người dùng',
                    prefixIcon: Icons.person_outlined,
                    keyboardType: TextInputType.text,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập tên người dùng'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Số điện thoại',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Vui lòng nhập số điện thoại'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mật khẩu',
                    prefixIcon: Icons.lock_outlined,
                    isPasswordField: true,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Vui lòng nhập mật khẩu'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  BlocConsumer<AuthService, AuthState>(
                    listener: (context, state) {
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
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthService>().add(
                              SignUpRequested(
                                _usernameController.text.trim(),
                                _phoneController.text.trim(),
                                _passwordController.text.trim(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Đăng Ký',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
