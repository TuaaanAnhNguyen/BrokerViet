// lib/widgets/profile/change_password_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/profile/profile_service.dart';
import '../custom_text_field.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Đổi mật khẩu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Mật khẩu mới nên có ít nhất 8 ký tự.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _passwordController,
                labelText: "Mật khẩu mới",
                prefixIcon: Icons.lock_outline,
                isPasswordField: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Không được để trống";
                  }

                  if (value.length < 8) {
                    return "Ít nhất 8 ký tự";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _confirmController,
                labelText: "Xác nhận mật khẩu",
                prefixIcon: Icons.lock_outline,
                isPasswordField: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return "Mật khẩu không khớp";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),

                  const SizedBox(width: 8),

                  ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      context.read<ProfileService>().add(
                        UpdatePasswordRequested(
                          newPassword: _passwordController.text,
                        ),
                      );

                      Navigator.pop(context);
                    },
                    child: const Text("Cập nhật"),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
