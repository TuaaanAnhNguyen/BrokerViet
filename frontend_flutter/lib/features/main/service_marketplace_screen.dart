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
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'PC Repair', 'icon': Icons.computer_rounded},
    {'label': 'Rentals', 'icon': Icons.precision_manufacturing_rounded},
  ];

  // Upgraded Mock Payload mapping to specific subcategories
  final List<ServiceModel> _allServices = const [
    ServiceModel(
      id: '1',
      title: 'Full System Diagnostic & Fix',
      subtitle: 'Laptop repair, PC troubleshooting & virus removal',
      providerName: 'TechPro VN',
      price: '\$45',
      rating: 4.9,
      tags: ['Repair', 'Warranty', 'Fast Delivery'],
    ),
    ServiceModel(
      id: '2',
      title: 'High-End Gaming PC Build',
      subtitle: 'Hardware replacement & performance optimization',
      providerName: 'Linh System',
      price: '\$75',
      rating: 5.0,
      tags: ['Repair', 'Expert Only'],
    ),
    ServiceModel(
      id: '3',
      title: 'PS5 & VR Headset Combo',
      subtitle: 'Next-gen console rental with 2 dualsense controllers',
      providerName: 'BrokerViet Core Rental',
      price: '\$30/day',
      rating: 4.8,
      tags: ['Rental', 'Gaming Device'],
    ),
    ServiceModel(
      id: '4',
      title: '4K Creator Monitor & Camera Kit',
      subtitle: 'Premium production setups & multi-monitor configurations',
      providerName: 'Danang Tech Equipment',
      price: '\$50/day',
      rating: 4.7,
      tags: ['Rental', 'Monitors'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Live Client-Side Filtering matching Active Tab Constraints
    final List<ServiceModel> filteredServices = _allServices.where((service) {
      if (_activeCategoryIndex == 0) return true; // 'All' Option
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
                hintText: 'Search services, repairs, rentals...',
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
              'Categories',
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

          // Promotional Card Block
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Container(
          //     height: 176,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(16),
          //       gradient: const LinearGradient(
          //         colors: [Color(0xFF004AC6), Color(0x00004AC6)],
          //         begin: Alignment.centerLeft,
          //         end: Alignment.centerRight,
          //       ),
          //       color: const Color(0xFF213145),
          //     ),
          //     child: Padding(
          //       padding: const EdgeInsets.all(24.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Text(
          //             'LIMITED OFFER',
          //             style: TextStyle(
          //               color: Colors.white70,
          //               fontSize: 11,
          //               letterSpacing: 1.5,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           const SizedBox(height: 4),
          //           const SizedBox(
          //             width: 200,
          //             child: Text(
          //               'Get 20% off your first PC Build',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 22,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           const SizedBox(height: 12),
          //           ElevatedButton(
          //             onPressed: () {},
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.white,
          //               foregroundColor: const Color(0xFF004AC6),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20),
          //               ),
          //               padding: const EdgeInsets.symmetric(
          //                 horizontal: 16,
          //                 vertical: 8,
          //               ),
          //               elevation: 0,
          //             ),
          //             child: const Text(
          //               'Claim Now',
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 24),

          // Nearby Providers Subsection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Providers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
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
                _buildNearbyProviderTile('TechPro VN', '0.8 km away', '4.9'),
                _buildNearbyProviderTile('Linh System', '1.2 km away', '4.8'),
                _buildNearbyProviderTile('FixIt Fast', '2.5 km away', '4.7'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Popular Services Section List View Blocks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _categories[_activeCategoryIndex]['label'] == 'All'
                  ? 'Popular Services'
                  : 'Available ${_categories[_activeCategoryIndex]['label']}',
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
                        'No services found in this category.',
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
