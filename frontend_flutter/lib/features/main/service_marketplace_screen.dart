// lib/features/main/service_marketplace_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/service_card.dart';
import './service_detail_screen.dart';

class ServiceMarketplaceScreen extends StatefulWidget {
  const ServiceMarketplaceScreen({super.key});

  @override
  State<ServiceMarketplaceScreen> createState() =>
      _ServiceMarketplaceScreenState();
}

class _ServiceMarketplaceScreenState extends State<ServiceMarketplaceScreen> {
  int _activeCategoryIndex = 0;

  // Cleaned Category List tailored precisely to project specifications
  final List<Map<String, dynamic>> _categories = [
    {'label': 'Tất cả', 'icon': Icons.grid_view_rounded},
    {'label': 'Sửa chữa thiết bị', 'icon': Icons.computer_rounded},
    {'label': 'Cho thuê thiết bị', 'icon': Icons.precision_manufacturing_rounded},
  ];

  // Upgraded Mock Payload mapping to specific subcategories
  final List<ServiceModel> _allServices = const [
    ServiceModel(
      id: '1',
      title: 'Chẩn đoán & Sửa chữa Toàn diện',
      subtitle: 'Sửa laptop, sửa PC, diệt virus',
      providerName: 'TechPro VN',
      price: '450.000 VND',
      rating: 4.9,
      tags: ['Repair', 'Warranty', 'Fast Delivery'],
    ),
    ServiceModel(
      id: '2',
      title: 'Lắp ráp PC Gaming Cấu hình cao',
      subtitle: 'Thay thế linh kiện & tối ưu hóa hiệu năng phần cứng',
      providerName: 'Linh System',
      price: '75.000.000 VND',
      rating: 5.0,
      tags: ['Repair', 'Expert Only'],
    ),
    ServiceModel(
      id: '3',
      title: 'Combo Máy PS5 & Kính thực tế ảo VR',
      subtitle: 'Thuê máy chơi game thế hệ mới kèm 2 tay cầm dualsense',
      providerName: 'BrokerViet Core Rental',
      price: '30.000 VND/ngày',
      rating: 4.8,
      tags: ['Rental', 'Gaming Device'],
    ),
    ServiceModel(
      id: '4',
      title: 'Bộ Màn hình Creator 4K & Máy ảnh',
      subtitle: 'Thiết lập không gian studio chuyên nghiệp & đa màn hình',
      providerName: 'Danang Tech Equipment',
      price: '50.000 VND/ngày',
      rating: 4.7,
      tags: ['Rental', 'Monitors'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Live Client-Side Filtering matching Active Tab Constraints
    final List<ServiceModel> filteredServices = _allServices.where((service) {
      if (_activeCategoryIndex == 0) return true; // 'Tất cả' Option
      if (_activeCategoryIndex == 1) return service.tags.contains('Repair');
      if (_activeCategoryIndex == 2) return service.tags.contains('Rental');
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Search Interactive Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm dịch vụ, sửa chữa, thuê thiết bị...',
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
                  onTap: () => setState(() => _activeCategoryIndex = index),
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
            child: filteredServices.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Không tìm thấy dịch vụ nào trong danh mục này.',
                        style: TextStyle(color: Colors.black38),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      return ServiceCard(
                        service: filteredServices[index],
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
              color: const Color(0xFF004AC6).withOpacity(0.7),
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