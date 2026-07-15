// lib/widgets/booking/booking_notes_input.dart

import 'package:flutter/material.dart';

class BookingNotesInput extends StatelessWidget {
  final TextEditingController controller;

  const BookingNotesInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú cho kỹ thuật viên',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Mô tả thêm về tình trạng máy hoặc hướng dẫn đường đi...',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}