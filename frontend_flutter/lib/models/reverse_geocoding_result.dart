// lib/models/reverse_geocoding_result.dart

class ReverseGeocodingResult {
  final String displayName;
  final String? address;
  final String? city;
  final String? province;
  final String? country;

  const ReverseGeocodingResult({
    required this.displayName,
    this.address,
    this.city,
    this.province,
    this.country,
  });

  factory ReverseGeocodingResult.fromJson(Map<String, dynamic> json) {
    return ReverseGeocodingResult(
      displayName: json['displayName']?.toString() ?? '',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'address': address,
      'city': city,
      'province': province,
      'country': country,
    };
  }
}
