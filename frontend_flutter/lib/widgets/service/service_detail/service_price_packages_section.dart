// lib/widgets/service/service_detail/service_price_packages_section.dart

import 'package:flutter/material.dart';
import '../../../widgets/voucher/voucher_badge.dart';

class ServicePricePackagesSection extends StatelessWidget {
  final String serviceId;
  final String? title;
  final String? price;
  final Color darkText;
  final Color bodyText;
  final Color primaryColor;

  const ServicePricePackagesSection({
    super.key,
    required this.serviceId,
    required this.title,
    required this.price,
    required this.darkText,
    required this.bodyText,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin chi phí',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC3C6D7), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Giá dịch vụ trọn gói',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chi phí dịch vụ niêm yết công khai',
                      style: TextStyle(color: bodyText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                price ?? 'Liên hệ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VoucherBadge(serviceId: serviceId),
      ],
    );
  }
}
