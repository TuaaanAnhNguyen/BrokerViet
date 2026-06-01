// lib/features/marketplace/service_marketplace_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/service_card.dart';

class ServiceMarketplaceScreen extends StatelessWidget {
  const ServiceMarketplaceScreen({super.key});

  final List<ServiceModel> _mockServices = const [
    ServiceModel(id: '1', title: 'Deep PC Cleaning & Thermal Paste', providerName: 'TechCare Da Nang', priceRange: '200.000đ - 350.000đ', rating: 4.9, imageUrl: ''),
    ServiceModel(id: '2', title: 'Custom Windows/MacOS Optimization', providerName: 'Minh Triet Computer', priceRange: '150.000đ', rating: 4.7, imageUrl: ''),
    ServiceModel(id: '3', title: 'RTX 4060 GPU Weekly Rental', providerName: 'BrokerViet Core Rental', priceRange: '500.000đ/week', rating: 4.8, imageUrl: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search PC services, rentals...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All Services', true),
                  _buildCategoryChip('PC Repair', false),
                  _buildCategoryChip('Hardware Rental', false),
                  _buildCategoryChip('Software Setup', false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _mockServices.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return ServiceCard(
                    service: _mockServices[index],
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}