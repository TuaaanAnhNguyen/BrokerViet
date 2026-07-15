import 'package:flutter/material.dart';

class SearchNoResultsState extends StatelessWidget {
  final String searchText;

  const SearchNoResultsState({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.find_in_page_rounded,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy kết quả nào khớp với "$searchText"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0B1C30),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vui lòng kiểm tra lại chính tả hoặc thử một danh mục từ khóa khác.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF737686), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
