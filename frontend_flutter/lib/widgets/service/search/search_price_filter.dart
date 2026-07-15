// lib/widgets/service/search/search_price_filter.dart

import 'package:flutter/material.dart';

class SearchPriceFilter extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final VoidCallback onSubmitted;

  const SearchPriceFilter({
    super.key,
    required this.minPriceController,
    required this.maxPriceController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: minPriceController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => onSubmitted(),
              decoration: _buildInputDecoration('Giá tối thiểu'),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: maxPriceController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => onSubmitted(),
              decoration: _buildInputDecoration('Giá tối đa'),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF737686), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFE5EEFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
