// lib/features/main/service_marketplace_screen.dart

import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../widgets/service/service_card.dart';
import '../../widgets/service/category_selector.dart';
import '../../widgets/service/nearby_provider_tile.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import './service_detail_screen.dart';
import './search_screen.dart';

class ServiceMarketplaceScreen extends StatefulWidget {
  const ServiceMarketplaceScreen({super.key});

  @override
  State<ServiceMarketplaceScreen> createState() => _ServiceMarketplaceScreenState();
}

class _ServiceMarketplaceScreenState extends State<ServiceMarketplaceScreen> {
  final ServiceMarketplaceService _marketplaceService = ServiceMarketplaceService();
  final TextEditingController _searchController = TextEditingController();
  
  int _activeCategoryIndex = 0;
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> _categories = [
    {'label': 'Tất cả', 'icon': Icons.grid_view_rounded, 'id': null},
  ];

  final List<Map<String, String>> _nearbyProviders = const [
    {'name': 'TechPro VN', 'distance': 'Cách đây 0.8 km', 'score': '4.9'},
    {'name': 'Linh System', 'distance': 'Cách đây 1.2 km', 'score': '4.8'},
    {'name': 'FixIt Fast', 'distance': 'Cách đây 2.5 km', 'score': '4.7'},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    Future.wait([
      _loadCategories(),
      _loadServices(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      print('>>> Bắt đầu gửi yêu cầu lấy danh mục từ DB...');
      
      final categoriesFromDb = await _marketplaceService
          .fetchServiceCategories()
          .timeout(const Duration(seconds: 10));
      
      print('>>> Kết quả trả về từ Service: ${categoriesFromDb.length} danh mục.');
      
      if (categoriesFromDb.isNotEmpty) {
        final List<Map<String, dynamic>> loadedCategories = [
          {'label': 'Tất cả', 'icon': Icons.grid_view_rounded, 'id': null},
        ];

        for (var cat in categoriesFromDb) {
          final String name = cat.name;
          IconData icon = Icons.work_outline;

          if (name.toLowerCase().contains('sửa') || name.toLowerCase().contains('repair')) {
            icon = Icons.computer_rounded;
          } else if (name.toLowerCase().contains('thuê') || name.toLowerCase().contains('rental')) {
            icon = Icons.precision_manufacturing_rounded;
          }

          loadedCategories.add({
            'label': name,
            'icon': icon,
            'id': cat.serviceCatId,
          });
        }

        if (mounted) {
          setState(() {
            _categories = loadedCategories;
          });
          print('>>> Đã cập nhật trạng thái UI với ${_categories.length} danh mục (bao gồm nút Tất cả).');
        }
      } else {
        print('>>> Database trả về danh sách danh mục rỗng.');
      }
    } catch (e) {
      print('>>> LỖI HOÀN TOÀN TẠI MÀN HÌNH UI KHI LOAD CATEGORIES: $e');
    }
  }

  Future<void> _loadServices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      print('>>> Bắt đầu tải danh sách dịch vụ...');
      final activeCat = _activeCategoryIndex < _categories.length 
          ? _categories[_activeCategoryIndex] 
          : {'id': null};
      
      final String? categoryId = _activeCategoryIndex == 0 
          ? null 
          : activeCat['id']?.toString();

      final results = await _marketplaceService
          .searchServices(
            categoryId: categoryId,
            search: _searchController.text.isEmpty ? null : _searchController.text,
          )
          .timeout(const Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          _services = results;
          _isLoading = false;
        });
        print('>>> Đã tải thành công ${results.length} dịch vụ.');
      }
    } catch (e) {
      print(">>> LỖI HOÀN TOÀN TẠI MÀN HÌNH UI KHI LOAD SERVICES: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategoryLabel = _activeCategoryIndex < _categories.length 
        ? _categories[_activeCategoryIndex]['label'] 
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadCategories();
          await _loadServices();
        },
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
            _buildSectionHeader(
              _activeCategoryIndex == 0 ? 'Dịch vụ phổ biến' : 'Dịch vụ $currentCategoryLabel',
            ),
            const SizedBox(height: 12),
            
            _buildServicesList(_services),
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
              hintStyle: const TextStyle(color: Color(0xFF737686), fontSize: 14),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: Color(0xFF004AC6), fontWeight: FontWeight.bold),
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
              MaterialPageRoute(builder: (context) => const ServiceDetailScreen()),
            ),
          );
        },
      ),
    );
  }
}