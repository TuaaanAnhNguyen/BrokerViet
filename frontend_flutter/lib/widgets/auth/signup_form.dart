// lib/widgets/auth/signup_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_service.dart';
import '../custom_text_field.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitSignUp() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      context.read<AuthService>().add(
            SignUpRequested(
              _usernameController.text.trim(),
              _phoneController.text.trim(),
              _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registration successful!'),
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
              if (state is AuthLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return ElevatedButton(
                onPressed: _submitSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đăng Ký',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}