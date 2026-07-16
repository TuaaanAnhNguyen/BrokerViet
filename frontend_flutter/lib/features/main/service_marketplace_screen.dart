// lib/features/main/service_marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_model.dart';
import '../../widgets/service/category_selector.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import '../../services/map-location/location_service.dart';
import '../../widgets/service/marketplace/market_search_bar.dart';
import '../../widgets/service/marketplace/service_list_section.dart';
import '../../widgets/service/marketplace/nearby_providers_section.dart';

class ServiceMarketplaceScreen extends StatefulWidget {
  const ServiceMarketplaceScreen({super.key});

  @override
  State<ServiceMarketplaceScreen> createState() =>
      _ServiceMarketplaceScreenState();
}

class _ServiceMarketplaceScreenState extends State<ServiceMarketplaceScreen> {
  final ServiceMarketplaceService _marketplaceService =
      ServiceMarketplaceService();
  final LocationService _locationService = LocationService();

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

  Future<void> _initData() async {
    await Future.wait([
      _loadCategories(),
      _loadServices(),
      _loadNearbyProviders(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesFromDb = await _marketplaceService
          .fetchServiceCategories()
          .timeout(const Duration(seconds: 10));

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
          setState(() => _categories = loadedCategories);
        }
      }
    } catch (e) {
      debugPrint('>>> LỖI TẢI DANH MỤC: $e');
    }
  }

  Future<void> _loadServices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final activeCat = _activeCategoryIndex < _categories.length
          ? _categories[_activeCategoryIndex]
          : {'id': null};

      final String? categoryId = _activeCategoryIndex == 0
          ? null
          : activeCat['id']?.toString();

      final results = await _marketplaceService
          .searchServices(categoryId: categoryId)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _services = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(">>> LỖI TẢI DỊCH VỤ: $e");
      if (mounted) setState(() => _isLoading = false);
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
      if (user == null) throw Exception("Chưa đăng nhập hệ thống.");

      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('location_latitude, location_longitude')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileData == null ||
          profileData['location_latitude'] == null ||
          profileData['location_longitude'] == null) {
        setState(() {
          _providerLocationError =
              "Vui lòng cập nhật địa chỉ để hiển thị đơn vị gần bạn.";
          _isLoadingProviders = false;
        });
        return;
      }

      final userLat = (profileData['location_latitude'] as num?)?.toDouble();
      final userLng = (profileData['location_longitude'] as num?)?.toDouble();

      if (userLat == null || userLng == null) {
        setState(() {
          _providerLocationError = "Cấu trúc tọa độ không hợp lệ.";
          _isLoadingProviders = false;
        });
        return;
      }

      final nearbyData = await _locationService.findNearbyProviders(
        latitude: userLat,
        longitude: userLng,
        radiusMeters: 15000,
        limit: 10,
      );

      if (!mounted) return;

      setState(() {
        _dynamicNearbyProviders = nearbyData;

        if (nearbyData.isEmpty) {
          _providerLocationError =
              "Không tìm thấy đơn vị cung cấp nào trong bán kính 15 km.";
        } else {
          _providerLocationError = null;
        }

        _isLoadingProviders = false;
      });
    } catch (e) {
      debugPrint('>>> LỖI LOAD SPATIAL DATA: $e');

      if (!mounted) return;

      setState(() {
        _providerLocationError = "Không thể tải danh sách đơn vị gần bạn.";
        _isLoadingProviders = false;
      });
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
        onRefresh: _initData,
        color: const Color(0xFF004AC6),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const MarketSearchBar(),
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
            NearbyProvidersSection(
              isLoading: _isLoadingProviders,
              errorMessage: _providerLocationError,
              providers: _dynamicNearbyProviders,
            ),
            const SizedBox(height: 24),
            ServicesListSection(
              title: _activeCategoryIndex == 0
                  ? 'Dịch vụ phổ biến'
                  : 'Dịch vụ $currentCategoryLabel',
              services: _getSortedServices(),
              isLoading: _isLoading,
              sortOrder: _sortOrder,
              onSortChanged: () {
                setState(() {
                  _sortOrder = (_sortOrder == 'none' || _sortOrder == 'desc')
                      ? 'asc'
                      : 'desc';
                });
              },
            ),
          ],
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
}
