// lib/widgets/service/search/search_empty_state.dart

import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64, color: Color(0xFFDCE9FF)),
          SizedBox(height: 12),
          Text(
            'Nhập từ khóa để tìm kiếm dịch vụ nhanh chóng',
            style: TextStyle(color: Color(0xFF737686), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
