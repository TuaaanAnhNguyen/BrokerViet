// lib/widgets/profile/edit_profile_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/profile/profile_service.dart';
import '../../models/profile_model.dart';

class EditProfileSheet extends StatefulWidget {
  final ProfileModel currentProfile;

  const EditProfileSheet({super.key, required this.currentProfile});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late String updatedName;
  late String updatedBio;
  late String updatedAddress;
  late String updatedOpen;
  late String updatedClose;
  late String updatedLocText;
  late String updatedBankCode;
  late String updatedBankAcc;

  @override
  void initState() {
    super.initState();
    updatedName = widget.currentProfile.username;
    updatedBio = widget.currentProfile.bio ?? '';
    updatedAddress = widget.currentProfile.address ?? '';
    updatedOpen = widget.currentProfile.openingHour ?? '';
    updatedClose = widget.currentProfile.closingHour ?? '';
    updatedLocText = widget.currentProfile.locationText ?? '';
    updatedBankCode = widget.currentProfile.payoutBankCode ?? '';
    updatedBankAcc = widget.currentProfile.payoutAccountNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final bool isProvider = widget.currentProfile.role?.toUpperCase() == 'PROVIDER';

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
              ),
              const SizedBox(height: 16),
              _buildFormLabel('Tên hiển thị'),
              _buildField(hint: 'Nhập tên mới', initialValue: updatedName, onChanged: (val) => updatedName = val),
              _buildFormLabel('Giới thiệu ngắn (Tiểu sử)'),
              _buildField(hint: 'Nhập giới thiệu kinh nghiệm...', initialValue: updatedBio, onChanged: (val) => updatedBio = val),
              _buildFormLabel('Địa chỉ thường trú'),
              _buildField(hint: 'Nhập địa chỉ nhà', initialValue: updatedAddress, onChanged: (val) => updatedAddress = val),
              
              if (isProvider) ...[
                const Divider(height: 32),
                const Text('Cấu hình kinh doanh (Đối Tác)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004AC6))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Giờ mở cửa'),
                          _buildField(hint: '08:00:00', initialValue: updatedOpen, onChanged: (val) => updatedOpen = val),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Giờ đóng cửa'),
                          _buildField(hint: '22:00:00', initialValue: updatedClose, onChanged: (val) => updatedClose = val),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildFormLabel('Tên hiển thị vị trí định vị'),
                _buildField(hint: 'Tòa nhà, số tầng...', initialValue: updatedLocText, onChanged: (val) => updatedLocText = val),
                _buildFormLabel('Mã ngân hàng'),
                _buildField(hint: 'VCB / TCB / MB', initialValue: updatedBankCode, onChanged: (val) => updatedBankCode = val),
                _buildFormLabel('Số tài khoản nhận Payout'),
                _buildField(hint: 'Nhập số tài khoản ngân hàng', initialValue: updatedBankAcc, onChanged: (val) => updatedBankAcc = val),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AC6)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updated = widget.currentProfile.copyWith(
                          username: updatedName,
                          bio: updatedBio,
                          address: updatedAddress,
                          openingHour: updatedOpen.isNotEmpty ? updatedOpen : null,
                          closingHour: updatedClose.isNotEmpty ? updatedClose : null,
                          locationText: updatedLocText.isNotEmpty ? updatedLocText : null,
                          payoutBankCode: updatedBankCode.isNotEmpty ? updatedBankCode : null,
                          payoutAccountNumber: updatedBankAcc.isNotEmpty ? updatedBankAcc : null,
                        );
                        context.read<ProfileService>().add(UpdateProfileRequested(updated));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
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
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7E84A2))),
    );
  }

  Widget _buildField({required String hint, required String initialValue, required ValueChanged<String> onChanged}) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}