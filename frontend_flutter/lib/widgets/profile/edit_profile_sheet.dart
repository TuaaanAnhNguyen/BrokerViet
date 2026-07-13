// lib/widgets/profile/edit_profile_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/profile/profile_service.dart';
import '../../models/profile_model.dart';
import '../custom_text_field.dart';

class EditProfileSheet extends StatefulWidget {
  final ProfileModel currentProfile;

  const EditProfileSheet({super.key, required this.currentProfile});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _addressController;
  late final TextEditingController _locTextController;
  late final TextEditingController _openController;
  late final TextEditingController _closeController;

  late final TextEditingController _bankCodeController;
  late final TextEditingController _bankAccountController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.currentProfile.username,
    );

    _bioController = TextEditingController(
      text: widget.currentProfile.bio ?? '',
    );

    _addressController = TextEditingController(
      text: widget.currentProfile.address ?? '',
    );
    _locTextController = TextEditingController(
      text: widget.currentProfile.locationText ?? '',
    );

    _openController = TextEditingController(
      text: widget.currentProfile.openingHour ?? '',
    );

    _closeController = TextEditingController(
      text: widget.currentProfile.closingHour ?? '',
    );

    _bankCodeController = TextEditingController(
      text: widget.currentProfile.payoutBankCode ?? '',
    );

    _bankAccountController = TextEditingController(
      text: widget.currentProfile.payoutAccountNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _locTextController.dispose();
    _openController.dispose();
    _closeController.dispose();
    _bankCodeController.dispose();
    _bankAccountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isProvider =
        widget.currentProfile.role?.toUpperCase() == 'PROVIDER';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cập nhật hồ sơ thông tin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormLabel('Tên hiển thị'),
              CustomTextField(
                controller: _nameController,
                labelText: 'Tên hiển thị',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tên hiển thị không được để trống';
                  }
                  return null;
                },
              ),
              _buildFormLabel('Giới thiệu ngắn (Tiểu sử)'),
              CustomTextField(
                controller: _bioController,
                labelText: 'Giới thiệu ngắn',
                prefixIcon: Icons.info_outline,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
              _buildFormLabel('Địa chỉ'),
              CustomTextField(
                controller: _addressController,
                labelText: 'Địa chỉ',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),

              if (isProvider) ...[
                const Divider(height: 32),
                const Text(
                  'Cấu hình kinh doanh (Đối Tác)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AC6),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Giờ mở cửa'),
                          CustomTextField(
                            controller: _openController,
                            labelText: 'Giờ mở cửa',
                            prefixIcon: Icons.access_time_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Giờ đóng cửa'),
                          CustomTextField(
                            controller: _closeController,
                            labelText: 'Giờ đóng cửa',
                            prefixIcon: Icons.access_time_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildFormLabel('Tên hiển thị vị trí định vị'),
                CustomTextField(
                  controller: _locTextController,
                  labelText: 'Tên hiển thị vị trí định vị',
                  prefixIcon: Icons.location_on_outlined,
                ),
                _buildFormLabel('Mã ngân hàng'),
                CustomTextField(
                  controller: _bankCodeController,
                  labelText: 'Mã ngân hàng',
                  prefixIcon: Icons.account_balance_outlined,
                ),
                _buildFormLabel('Số tài khoản nhận Payout'),
                CustomTextField(
                  controller: _bankAccountController,
                  labelText: 'Số tài khoản nhận Payout',
                  prefixIcon: Icons.account_balance_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AC6),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updated = widget.currentProfile.copyWith(
                          username: _nameController.text.trim(),
                          bio: _bioController.text.trim(),
                          address: _addressController.text.trim(),
                          openingHour: _openController.text.trim().isEmpty
                              ? null
                              : _openController.text.trim(),
                          closingHour: _closeController.text.trim().isEmpty
                              ? null
                              : _closeController.text.trim(),
                          locationText: _locTextController.text.trim().isEmpty
                              ? null
                              : _locTextController.text.trim(),
                          payoutBankCode:
                              _bankCodeController.text.trim().isEmpty
                              ? null
                              : _bankCodeController.text.trim(),
                          payoutAccountNumber:
                              _bankAccountController.text.trim().isEmpty
                              ? null
                              : _bankAccountController.text.trim(),
                        );
                        context.read<ProfileService>().add(
                          UpdateProfileRequested(updated),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Lưu thay đổi',
                      style: TextStyle(color: Colors.white),
                    ),
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

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7E84A2),
        ),
      ),
    );
  }
}
