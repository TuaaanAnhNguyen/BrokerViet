// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_service.dart';
import 'signup_screen.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.build_circle_outlined,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'BrokerViet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

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
                    listenWhen: (previous, current) =>
                        current is AuthSuccess || current is AuthFailure,
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Chào mừng bạn quay trở lại, ${state.name}!',
                            ),
                          ),
                        );
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
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Hide onscreen keyboard cleanly before sending state request
                            FocusScope.of(context).unfocus();

                            context.read<AuthService>().add(
                              LoginRequested(
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Đăng Nhập',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        text: "Chưa có tài khoản? ",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Đăng ký ngay",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
