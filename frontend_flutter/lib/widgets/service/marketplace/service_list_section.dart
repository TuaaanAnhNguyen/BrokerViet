import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../widgets/service/service_card.dart';
import '../../../features/main/service_detail_screen.dart';

class ServicesListSection extends StatelessWidget {
  final String title;
  final List<ServiceModel> services;
  final bool isLoading;
  final String sortOrder;
  final VoidCallback onSortChanged;

  const ServicesListSection({
    super.key,
    required this.title,
    required this.services,
    required this.isLoading,
    required this.sortOrder,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
                onTap: onSortChanged,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sortOrder != 'none'
                        ? const Color(0xFF004AC6)
                        : const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sortOrder == 'desc'
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        size: 14,
                        color: sortOrder != 'none'
                            ? Colors.white
                            : const Color(0xFF004AC6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sortOrder == 'desc' ? 'Giá cao' : 'Giá thấp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sortOrder != 'none'
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
        ),
        const SizedBox(height: 12),
        _buildMainContent(context),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (isLoading) {
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
}
