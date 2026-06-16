// lib/models/service_model.dart

class ServiceModel {
  final String id;
  final String title;
  final String subtitle;
  final String providerId;
  final String? categoryId;
  final String? categoryName;
  final String price;
  final double rating;
  final List<String> tags;
  final String? imageUrl;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.providerId,
    this.categoryId,
    this.categoryName,
    required this.price,
    required this.rating,
    required this.tags,
    this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String formatPrice(dynamic rawPrice) {
      if (rawPrice == null) return 'Liên hệ';
      try {
        final double value = double.parse(rawPrice.toString());
        return "${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
      } catch (_) {
        return '$rawPrice đ';
      }
    }

    return ServiceModel(
      id: (json['service_id'] ?? '').toString(),
      title: json['title'] ?? 'Chưa có tiêu đề',
      subtitle: json['description'] ?? '',
      providerId: (json['provider_id'] ?? '').toString(),
      categoryId: json['service_cat_id']?.toString(),
      categoryName: json['category_name'],
      price: formatPrice(json['price']),
      rating: (json['rating'] ?? 5.0).toDouble(),
      tags: json['category_name'] != null ? [json['category_name'].toString()] : [],
      imageUrl: json['image_url']?.toString() ?? 'assets/no_image_placeholder.png',
    );
  }
}