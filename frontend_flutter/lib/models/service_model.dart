// lib/models/service_model.dart

class ServiceModel {
  final String id;
  final String title;
  final String subtitle;
  final String providerId;
  final String? providerUsername;
  final String? providerAvatarUrl;
  final String? categoryId;
  final String? categoryName;
  final String price;
  final double priceValue;
  final double rating;
  final List<String> tags;
  final String? imageUrl;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.providerId,
    this.providerUsername,
    this.providerAvatarUrl,
    this.categoryId,
    this.categoryName,
    required this.price,
    required this.priceValue,
    required this.rating,
    required this.tags,
    this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String formatPrice(dynamic rawPrice) {
      if (rawPrice == null) return 'Liên hệ';
      try {
        final double value = double.parse(rawPrice.toString());
        return "${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
      } catch (_) {
        return '$rawPrice đ';
      }
    }

    final profilesData = json['profiles'];
    final String? extractedUsername = profilesData is Map<String, dynamic>
        ? profilesData['username']?.toString()
        : json['provider_username']?.toString();

    final String? extractedAvatarUrl = profilesData is Map<String, dynamic>
        ? profilesData['avatar_url']?.toString()
        : json['provider_avatar_url']?.toString();

    final categoriesData = json['service_categories'];
    final String? extractedCategoryName = categoriesData is Map<String, dynamic>
        ? categoriesData['name']?.toString()
        : json['category_name']?.toString();

    return ServiceModel(
      id: (json['service_id'] ?? '').toString(),
      title: json['title'] ?? 'Chưa có tiêu đề',
      subtitle: json['description'] ?? '',
      providerId: (json['provider_id'] ?? '').toString(),
      providerUsername: extractedUsername,
      providerAvatarUrl: extractedAvatarUrl,
      categoryId: json['service_cat_id']?.toString(),
      categoryName: extractedCategoryName,
      price: formatPrice(json['price']),
      priceValue: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      rating: (json['rating'] ?? 5.0).toDouble(),
      tags: extractedCategoryName != null
          ? [extractedCategoryName]
          : (json['category_name'] != null ? [json['category_name'].toString()] : []),
      imageUrl: json['image_url']?.toString() ?? 'assets/no_icon_placeholder.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': subtitle,
      'provider_id': providerId,
      'service_cat_id': categoryId,
      'price': priceValue,
      'image_url': imageUrl,
      'rating': rating,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? providerId,
    String? providerUsername,
    String? providerAvatarUrl,
    String? categoryId,
    String? categoryName,
    String? price,
    double? priceValue,
    double? rating,
    List<String>? tags,
    String? imageUrl,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      providerId: providerId ?? this.providerId,
      providerUsername: providerUsername ?? this.providerUsername,
      providerAvatarUrl: providerAvatarUrl ?? this.providerAvatarUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      priceValue: priceValue ?? this.priceValue,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}