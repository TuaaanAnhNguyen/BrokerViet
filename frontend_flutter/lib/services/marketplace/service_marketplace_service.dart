import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/service_model.dart';

class ServiceMarketplaceService {
  final String _baseUrl;

  ServiceMarketplaceService({String? baseUrl})
    : _baseUrl =
          baseUrl ??
          dotenv.env['BACKEND_URL'] ??
          (kIsWeb ? 'http://localhost:5077' : 'http://10.0.2.2:5077');

  Future<List<ServiceModel>> searchServices({
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    final Map<String, String> queryParameters = {};

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'null') {
      queryParameters['CategoryId'] = categoryId;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['Search'] = search.trim();
    }
    if (minPrice != null) {
      queryParameters['MinPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParameters['MaxPrice'] = maxPrice.toString();
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl/api/Service/search',
      ).replace(queryParameters: queryParameters);

      print('>>> Flutter Request URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ServiceModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Backend returned code ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('Error calling search service API endpoint: $e');
      rethrow;
    }
  }
}
