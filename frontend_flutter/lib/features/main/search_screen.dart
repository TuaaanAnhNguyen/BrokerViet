// lib/features/main/search_screen.dart

import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import '../../widgets/service/service_card.dart';
import './service_detail_screen.dart';

class ServiceSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const ServiceSearchScreen({super.key, this.initialQuery});

  @override
  State<ServiceSearchScreen> createState() => _ServiceSearchScreenState();
}

class _ServiceSearchScreenState extends State<ServiceSearchScreen> {
  final ServiceMarketplaceService _marketplaceService = ServiceMarketplaceService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ServiceModel> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // Direct integration into your classmate's .NET routing endpoint handler
      final results = await _marketplaceService.searchServices(
        search: query,
      );
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0B1C30), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: widget.initialQuery == null,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm dịch vụ, sửa chữa...',
                hintStyle: const TextStyle(color: Color(0xFF737686), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF737686), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(Icons.clear, color: Color(0xFF737686), size: 20),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF0B1C30)),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
              ),
            )
          : !_hasSearched
              ? _buildEmptySearchState()
              : _searchResults.isEmpty
                  ? _buildNoResultsState()
                  : _buildResultsList(),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.find_in_page_rounded, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy kết quả nào khớp với "${_searchController.text}"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF0B1C30), fontWeight: FontWeight.w600, fontSize: 15),
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

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ServiceCard(
          service: _searchResults[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ServiceDetailScreen(),
              ),
            );
          },
        );
      },
    );
  }
}