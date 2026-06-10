// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/login_form.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        const AuthHeader(),
                        const SizedBox(height: 40),
                        const LoginForm(),
                        const SizedBox(height: 16),
                        _buildSignUpLink(context),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return TextButton(
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
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
