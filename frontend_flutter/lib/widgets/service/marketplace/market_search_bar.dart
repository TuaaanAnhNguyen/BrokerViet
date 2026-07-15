import 'package:flutter/material.dart';
import '../../../features/main/search_screen.dart';

class MarketSearchBar extends StatelessWidget {
  const MarketSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceSearchScreen(),
            ),
          );
        },
        child: AbsorbPointer(
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm dịch vụ, sửa chữa, thuê thiết bị...',
              hintStyle: const TextStyle(
                color: Color(0xFF737686),
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF737686)),
              filled: true,
              fillColor: const Color(0xFFE5EEFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
