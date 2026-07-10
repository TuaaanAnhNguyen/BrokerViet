// lib/features/main/service_marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_model.dart';
import '../../widgets/service/service_card.dart';
import '../../widgets/service/category_selector.dart';
import '../../widgets/service/nearby_provider_tile.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import '../../services/map/map_service.dart';
import './service_detail_screen.dart';
import './search_screen.dart';

class ServiceMarketplaceScreen extends StatefulWidget {
  const ServiceMarketplaceScreen({super.key});

  @override
  State<ServiceMarketplaceScreen> createState() =>
      _ServiceMarketplaceScreenState();
}

class _ServiceMarketplaceScreenState extends State<ServiceMarketplaceScreen> {
  final ServiceMarketplaceService _marketplaceService =
      ServiceMarketplaceService();
  final MapService _mapService = MapService();
  final TextEditingController _searchController = TextEditingController();

  int _activeCategoryIndex = 0;
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String _sortOrder = 'none';
  List<Map<String, dynamic>> _categories = [
    {'label': 'Tất cả', 'icon': Icons.grid_view_rounded, 'id': null},
  ];

  List<Map<String, dynamic>> _dynamicNearbyProviders = [];
  bool _isLoadingProviders = false;
  String? _providerLocationError;

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
    await Future.wait([
      _loadCategories(),
      _loadServices(),
      _loadNearbyProviders(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      print('\n\n>>> Bắt đầu gửi yêu cầu lấy danh mục từ DB...');

      final categoriesFromDb = await _marketplaceService
          .fetchServiceCategories()
          .timeout(const Duration(seconds: 10));

      print(
        '\n\n>>> Kết quả trả về từ Service: ${categoriesFromDb.length} danh mục.',
      );

      if (categoriesFromDb.isNotEmpty) {
        final List<Map<String, dynamic>> loadedCategories = [
          {'label': 'Tất cả', 'icon': Icons.grid_view_rounded, 'id': null},
        ];

        for (var cat in categoriesFromDb) {
          final String name = cat.name;
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
            'id': cat.serviceCatId,
          });
        }

        if (mounted) {
          setState(() {
            _categories = loadedCategories;
          });
          print(
            '\n\n>>> Đã cập nhật trạng thái UI với ${_categories.length} danh mục (bao gồm nút Tất cả).',
          );
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
            search: _searchController.text.isEmpty
                ? null
                : _searchController.text,
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

  Future<void> _loadNearbyProviders() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProviders = true;
      _providerLocationError = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("Chưa đăng nhập hệ thống.");
      }

      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('address, location_latitude, location_longitude')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileData == null || profileData['location_latitude'] == null || profileData['location_longitude'] == null) {
        setState(() {
          _providerLocationError =
              "Vui lòng cập nhật địa chỉ để hiển thị đơn vị gần bạn.";
          _isLoadingProviders = false;
        });
        return;
      }

      // Note: If location point comes as a GeoJSON map string or GeoJSON map object from Supabase:
      // {'type': 'Point', 'coordinates': [lng, lat]}
      final userLat = (profileData['location_latitude'] as num?)?.toDouble();

      final userLng = (profileData['location_longitude'] as num?)?.toDouble();

      if (userLat == null || userLng == null) {
        setState(() {
          _providerLocationError = "Cấu trúc tọa độ không hợp lệ.";
          _isLoadingProviders = false;
        });
        return;
      }

      final nearbyData = await _mapService.findNearbyProviders(
        latitude: userLat,
        longitude: userLng,
        radiusMeters: 15000, // Search up to 15km
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _dynamicNearbyProviders = nearbyData;
          _isLoadingProviders = false;
        });
      }
    } catch (e) {
      print('>>> LỖI KHI LOAD PROVIDERS SPATIAL DATA: $e');
      if (mounted) {
        setState(() {
          _providerLocationError = "Không thể tải danh sách đơn vị gần bạn.";
          _isLoadingProviders = false;
        });
      }
    }
  }

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
    final currentCategoryLabel = _activeCategoryIndex < _categories.length
        ? _categories[_activeCategoryIndex]['label']
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadCategories(),
            _loadServices(),
            _loadNearbyProviders(),
          ]);
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
                onPressed: _providerLocationError == null ? () {} : null,
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
        _buildNearbyContent(),
      ],
    );
  }

  Widget _buildNearbyContent() {
    if (_isLoadingProviders) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
          ),
        ),
      );
    }

    if (_providerLocationError != null) {
      return Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCCC7)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _providerLocationError!,
                style: const TextStyle(
                  color: Color(0xFFA8071A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_dynamicNearbyProviders.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Không tìm thấy đơn vị nào quanh khu vực của bạn.',
            style: TextStyle(color: Colors.black38, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _dynamicNearbyProviders.length,
        itemBuilder: (context, index) {
          final item = _dynamicNearbyProviders[index];

          // Formating distance clean display string from database metric response
          final double distanceMeters = (item['distance_meters'] as num? ?? 0)
              .toDouble();
          final String distanceStr = distanceMeters >= 1000
              ? 'Cách ${(distanceMeters / 1000).toStringAsFixed(1)} km'
              : 'Cách ${distanceMeters.toStringAsFixed(0)} m';

          return NearbyProviderTile(
            name: item['username'] ?? item['email'] ?? 'Đơn vị ẩn danh',
            distance: distanceStr,
            // score:
            //     '4.8', // You can fallback or wire up your reviews logic later
          );
        },
      ),
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
                builder: (context) =>
                    ServiceDetailScreen(serviceId: services[index].id),
              ),
            ),
          );
        },
      ),
    );
  }

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
}
