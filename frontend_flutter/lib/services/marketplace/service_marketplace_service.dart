import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/service_model.dart';

class ServiceMarketplaceService {
  final String _baseUrl;

  ServiceMarketplaceService({String? baseUrl})
      : _baseUrl = baseUrl ??
            dotenv.env['BACKEND_URL'] ??
            (kIsWeb ? 'http://localhost:5077' : 'http://10.0.2.2:5077');

  Future<List<ServiceModel>> searchServices({
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['CategoryId'] = categoryId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['Search'] = search;
      }
      if (minPrice != null) {
        queryParams['MinPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['MaxPrice'] = maxPrice.toString();
      }
      if (limit != null) {
        queryParams['Limit'] = limit.toString();
      }
      if (offset != null) {
        queryParams['Offset'] = offset.toString();
      }

      final uri = Uri.parse('$_baseUrl/api/Service/search').replace(queryParameters: queryParams);
      print('Calling: $uri');
      print('QueryParams: $queryParams');
      final response = await http.get(uri);
      print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => ServiceModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty list on connection error or exception
      print('ServiceMarketplaceService error: $e');
      return [];
    }
  }
}
