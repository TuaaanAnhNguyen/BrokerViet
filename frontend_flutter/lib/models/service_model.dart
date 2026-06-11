// lib/models/service_model.dart

class ServiceModel {
  final String id;
  final String title;
  final String subtitle;
  final String providerName;
  final String price;
  final double rating;
  final List<String> tags;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.providerName,
    required this.price,
    required this.rating,
    required this.tags,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final priceVal = json['price'];
    String formattedPrice = 'Liên hệ';

    if (priceVal != null) {
      final parsedPrice = double.tryParse(priceVal.toString())?.toInt();
      if (parsedPrice != null) {
        final buffer = StringBuffer();
        final priceStr = parsedPrice.toString();
        int count = 0;
        for (int i = priceStr.length - 1; i >= 0; i--) {
          buffer.write(priceStr[i]);
          count++;
          if (count % 3 == 0 && i > 0) {
            buffer.write('.');
          }
        }
        formattedPrice = '${buffer.toString().split('').reversed.join()} VND';
      }
    }

    return ServiceModel(
      id: json['service_id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['description'] ?? '',
      providerName: json['category_name'] ?? 'Nhà cung cấp',
      price: formattedPrice,
      rating: 4.9,
      tags: json['category_name'] != null ? [json['category_name']] : [],
    );
  }
}
