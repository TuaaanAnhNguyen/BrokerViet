// lib/widgets/auth/phone_input_fields.dart

import 'package:flutter/material.dart';
import '../custom_text_field.dart';

class PhoneInputFields extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isEnabled;

  const PhoneInputFields({
    super.key,
    required this.phoneController,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: phoneController,
      labelText: 'Số điện thoại',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      enabled: isEnabled,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập số điện thoại';
        }
        final cleanedValue = value.trim().replaceAll(RegExp(r'\s+'), '');
        if (!RegExp(r'^[0-9]{9,11}$').hasMatch(cleanedValue)) {
          return 'Định dạng số điện thoại chưa đúng';
        }
        return null;
      },
    );
  }
}
