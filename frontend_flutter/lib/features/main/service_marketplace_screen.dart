// lib/features/main/service_marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/service_card.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import './service_detail_screen.dart';

class ServiceMarketplaceScreen extends StatefulWidget {
  const ServiceMarketplaceScreen({super.key});

  @override
  State<ServiceMarketplaceScreen> createState() =>
      _ServiceMarketplaceScreenState();
}

class _ServiceMarketplaceScreenState extends State<ServiceMarketplaceScreen> {
  final ServiceMarketplaceService _marketplaceService = ServiceMarketplaceService();
  final TextEditingController _searchController = TextEditingController();
  
  int _activeCategoryIndex = 0;
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> _categories = [
    {'label': 'Tất cả', 'icon': Icons.grid_view_rounded, 'id': null},
    {'label': 'Sửa chữa thiết bị', 'icon': Icons.computer_rounded, 'id': null},
    {'label': 'Cho thuê thiết bị', 'icon': Icons.precision_manufacturing_rounded, 'id': null},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await Supabase.instance.client
          .from('service_categories')
          .select();
      if (data.isNotEmpty) {
        final List<Map<String, dynamic>> loadedCategories = [
          {'label': 'Tất cả', 'icon': Icons.grid_view_rounded, 'id': null},
        ];
        for (var item in data) {
          final String name = item['name'] ?? '';
          IconData icon = Icons.work_outline;
          if (name.toLowerCase().contains('sửa') || name.toLowerCase().contains('repair')) {
            icon = Icons.computer_rounded;
          } else if (name.toLowerCase().contains('thuê') || name.toLowerCase().contains('rental')) {
            icon = Icons.precision_manufacturing_rounded;
          }
          loadedCategories.add({
            'label': name,
            'icon': icon,
            'id': item['service_cat_id'],
          });
        }
        if (mounted) {
          setState(() {
            _categories = loadedCategories;
          });
        }
      }
    } catch (e) {
      print('Error loading categories from Supabase: $e');
    }
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final activeCat = _categories[_activeCategoryIndex];
      final categoryId = activeCat['id']?.toString();
      final results = await _marketplaceService.searchServices(
        categoryId: categoryId,
        search: _searchController.text,
      );
      if (mounted) {
        setState(() {
          _services = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Search Interactive Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _loadServices(),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm dịch vụ, sửa chữa, thuê thiết bị...',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF737686)),
                    onPressed: _loadServices,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF737686)),
                          onPressed: () {
                            _searchController.clear();
                            _loadServices();
                          },
                        )
                      : null,
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
            const SizedBox(height: 24),
  
            // Categories Horizontal Scroller Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Danh mục dịch vụ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _activeCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeCategoryIndex = index);
                      _loadServices();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 80,
                      child: Column(
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF39B8FD)
                                  : const Color(0xFFDCE9FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _categories[index]['icon'],
                              size: 32,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF004AC6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _categories[index]['label'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
  
            // Nearby Providers Subsection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đơn vị cung cấp gần bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Color(0xFF004AC6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNearbyProviderTile('TechPro VN', 'Cách đây 0.8 km', '4.9'),
                  _buildNearbyProviderTile('Linh System', 'Cách đây 1.2 km', '4.8'),
                  _buildNearbyProviderTile('FixIt Fast', 'Cách đây 2.5 km', '4.7'),
                ],
              ),
            ),
            const SizedBox(height: 24),
  
            // Popular Services Section List View Blocks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _categories[_activeCategoryIndex]['label'] == 'Tất cả'
                    ? 'Dịch vụ phổ biến'
                    : 'Dịch vụ ${_categories[_activeCategoryIndex]['label']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _services.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              'Không tìm thấy dịch vụ nào.',
                              style: TextStyle(color: Colors.black38),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            return ServiceCard(
                              service: _services[index],
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
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyProviderTile(String name, String distance, String score) {
    return Container(
      width: 144,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE5EEFF),
            child: Icon(
              Icons.person,
              color: const Color(0xFF004AC6).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            distance,
            style: const TextStyle(color: Color(0xFF434655), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 2),
              Text(
                score,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006591),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}