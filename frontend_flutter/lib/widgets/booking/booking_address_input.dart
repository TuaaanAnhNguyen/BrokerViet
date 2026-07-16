// lib/widgets/booking/booking_address_input.dart

import 'package:flutter/material.dart';

class BookingAddressInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFetchCurrentLocation;
  final bool isLoading;

  const BookingAddressInput({
    super.key,
    required this.controller,
    required this.onFetchCurrentLocation,
    this.isLoading = false,
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
          'Địa điểm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: (value) =>
              value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
          style: const TextStyle(fontSize: 14, color: darkText),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on, color: primaryColor),
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onFetchCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39B8FD),
                  foregroundColor: const Color(0xFF004666),
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF004666),
                          ),
                        ),
                      )
                    : const Text(
                        'Hiện tại',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
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
