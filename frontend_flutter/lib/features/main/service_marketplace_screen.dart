// lib/features/main/service_marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_model.dart';
import '../../widgets/service/service_card.dart';
import '../../widgets/service/category_selector.dart';
import '../../widgets/service/nearby_provider_tile.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import './service_detail_screen.dart';
import './search_screen.dart';

String _sortOrder = 'none'; // 'none', 'asc', 'desc'

class ServiceMarketplaceScreen extends StatefulWidget {
  const ServiceMarketplaceScreen({super.key});

  @override
  State<ServiceMarketplaceScreen> createState() =>
      _ServiceMarketplaceScreenState();
}

class _ServiceMarketplaceScreenState extends State<ServiceMarketplaceScreen> {
  final ServiceMarketplaceService _marketplaceService =
      ServiceMarketplaceService();
  final TextEditingController _searchController = TextEditingController();

  int _activeCategoryIndex = 0;
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> _categories = [
    {'label': 'Tất cả', 'icon': Icons.grid_view_rounded, 'id': null},
    {
      'label': 'Sửa chữa thiết bị',
      'icon': Icons.precision_manufacturing_rounded,
      'id': null,
    },
    {'label': 'Cho thuê thiết bị', 'icon': Icons.computer_rounded, 'id': null},
  ];

  final List<Map<String, String>> _nearbyProviders = const [
    {'name': 'TechPro VN', 'distance': 'Cách đây 0.8 km', 'score': '4.9'},
    {'name': 'Linh System', 'distance': 'Cách đây 1.2 km', 'score': '4.8'},
    {'name': 'FixIt Fast', 'distance': 'Cách đây 2.5 km', 'score': '4.7'},
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
          if (name.toLowerCase().contains('sửa') ||
              name.toLowerCase().contains('repair')) {
            icon = Icons.computer_rounded;
          } else if (name.toLowerCase().contains('thuê') ||
              name.toLowerCase().contains('rental')) {
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
      print('>>> categories: $data');
    } catch (e) {
      print('Error loading categories from Supabase: $e');
    }
  }

  Future<void> _loadServices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final activeCat = _categories[_activeCategoryIndex];

      final String? categoryId = _activeCategoryIndex == 0
          ? null
          : activeCat['id']?.toString();

      final results = await _marketplaceService.searchServices(
        categoryId: categoryId,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      if (mounted) {
        setState(() {
          _services = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching marketplace entries: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ← THÊM: sort services theo priceValue
  List<ServiceModel> _getSortedServices() {
    final sorted = List<ServiceModel>.from(_services);
    if (_sortOrder == 'asc') {
      sorted.sort((a, b) => a.priceValue.compareTo(b.priceValue));
    } else if (_sortOrder == 'desc') {
      sorted.sort((a, b) => b.priceValue.compareTo(a.priceValue));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final currentCategoryLabel = _categories[_activeCategoryIndex]['label'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: RefreshIndicator(
        onRefresh: _loadServices,
        color: const Color(0xFF004AC6),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildSectionHeader('Danh mục dịch vụ'),
            const SizedBox(height: 12),

            CategorySelector(
              activeIndex: _activeCategoryIndex,
              categories: _categories,
              onCategorySelected: (index) {
                setState(() => _activeCategoryIndex = index);
                _loadServices();
              },
            ),
            const SizedBox(height: 24),
            _buildNearbyProvidersSection(),
            const SizedBox(height: 24),
            _buildServicesSectionHeader(
              _activeCategoryIndex == 0
                  ? 'Dịch vụ phổ biến'
                  : 'Dịch vụ $currentCategoryLabel',
            ),
            const SizedBox(height: 12),

            _buildServicesList(_getSortedServices()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0B1C30),
        ),
      ),
    );
  }

  // ← THÊM: section header riêng cho services, có nút sort
  Widget _buildServicesSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B1C30),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_sortOrder == 'none' || _sortOrder == 'desc') {
                  _sortOrder = 'asc';
                } else {
                  _sortOrder = 'desc';
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _sortOrder != 'none'
                    ? const Color(0xFF004AC6)
                    : const Color(0xFFE5EEFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _sortOrder == 'desc'
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 14,
                    color: _sortOrder != 'none'
                        ? Colors.white
                        : const Color(0xFF004AC6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortOrder == 'desc' ? 'Giá cao' : 'Giá thấp',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _sortOrder != 'none'
                          ? Colors.white
                          : const Color(0xFF004AC6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyProvidersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _nearbyProviders.length,
            itemBuilder: (context, index) {
              final provider = _nearbyProviders[index];
              return NearbyProviderTile(
                name: provider['name']!,
                distance: provider['distance']!,
                score: provider['score']!,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(List<ServiceModel> services) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
          ),
        ),
      );
    }

    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'Không tìm thấy dịch vụ nào trong danh mục này.',
            style: TextStyle(color: Colors.black38, fontSize: 14),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return ServiceCard(
            service: services[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ServiceDetailScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
