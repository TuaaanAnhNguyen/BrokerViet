// lib/widgets/profile/change_email_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/profile/profile_service.dart';
import '../custom_text_field.dart';

class ChangeEmailSheet extends StatefulWidget {
  final String currentEmail;

  const ChangeEmailSheet({super.key, required this.currentEmail});

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                "Thay đổi Email",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Một email xác thực sẽ được gửi đến địa chỉ mới.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _emailController,
                labelText: "Email mới",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Không được để trống";
                  }

                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

                  if (!emailRegex.hasMatch(value.trim())) {
                    return "Email không hợp lệ";
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
                        UpdateEmailRequested(_emailController.text.trim()),
                      );

                      Navigator.pop(context);
                    },
                    child: const Text("Gửi xác thực"),
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
