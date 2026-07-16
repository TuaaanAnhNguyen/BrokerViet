// lib/widgets/auth/email_input_field.dart

import 'package:flutter/material.dart';
import '../custom_text_field.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController emailController;
  final bool isEnabled;

  const EmailInputField({
    super.key,
    required this.emailController,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: emailController,
      labelText: 'Email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      enabled: isEnabled,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập email';
        }

        if (!RegExp(
          r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(value.trim())) {
          return 'Email không hợp lệ';
        }

        return null;
      },
    );
  }
}
