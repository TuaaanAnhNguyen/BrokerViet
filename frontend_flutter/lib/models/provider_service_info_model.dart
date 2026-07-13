// lib/models/provider_service_info_model.dart

class ProviderServiceInfo {
  final String serviceId;
  final String providerId;

  final String providerName;

  final String title;
  final String description;

  final double price;
  final double rating;

  final String? imageUrl;

  final String? categoryName;

  const ProviderServiceInfo({
    required this.serviceId,
    required this.providerId,
    required this.providerName,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    this.imageUrl,
    this.categoryName,
  });

  factory ProviderServiceInfo.fromJson(Map<String, dynamic> json) {
    return ProviderServiceInfo(
      serviceId: json['service_id'].toString(),
      providerId: json['provider_id'].toString(),
      providerName: json['provider_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'],
      categoryName: json['category_name'],
    );
  }
}
