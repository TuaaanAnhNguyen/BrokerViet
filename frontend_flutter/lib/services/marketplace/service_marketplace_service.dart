import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_model.dart';
import '../../models/service_category_model.dart';
import 'dart:convert';

class ServiceMarketplaceService {
  final _supabase = Supabase.instance.client;

  Future<List<ServiceModel>> searchServices({
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    int? limit,
    int? offset,
  }) async {
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      throw ArgumentError('MinPrice cannot be greater than MaxPrice.');
    }

    final params = <String, dynamic>{
      'p_limit': _normalizeLimit(limit),
      'p_offset': _normalizeOffset(offset),
      'p_category_id':
          (categoryId != null && categoryId.isNotEmpty && categoryId != 'null')
          ? categoryId
          : null,
      'p_search': (search != null && search.trim().isNotEmpty)
          ? search.trim()
          : null,
      'p_min_price': minPrice,
      'p_max_price': maxPrice,
    };

    try {
      final response = await _supabase.functions.invoke(
        'get-services',
        body: params,
      );

      if (response.status != 200) {
        final err = (response.data as Map?)?['error'] ?? 'Unknown error';
        throw Exception('Edge Function lỗi: $err');
      }

      List<dynamic> dataList;
      if (response.data is String) {
        dataList = jsonDecode(response.data as String) as List<dynamic>;
      } else if (response.data is List) {
        dataList = response.data as List<dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      return dataList.map((item) {
        try {
          print('>>> Item raw: $item');
          return ServiceModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('>>> Lỗi ép kiểu Model tại item: $item. Chi tiết: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('>>> Lỗi khi gọi RPC get_services_list: $e');
      rethrow;
    }
  }

  int _normalizeLimit(int? limit) {
    const defaultLimit = 20;
    const maxLimit = 100;
    if (limit == null || limit <= 0) return defaultLimit;
    return limit > maxLimit ? maxLimit : limit;
  }

  int _normalizeOffset(int? offset) {
    if (offset == null || offset < 0) return 0;
    return offset;
  }

  Future<List<ServiceCategoryModel>> fetchServiceCategories() async {
    try {
      final response = await _supabase.from('service_categories').select();

      return response.map((item) {
        try {
          print('>>> Đã fetch được: $item');
          return ServiceCategoryModel(
            serviceCatId: (item['service_cat_id'] ?? '').toString(),
            name: item['name'] ?? 'Chưa có tên',
          );
        } catch (e) {
          print('>>> Lỗi ép kiểu Category Model tại item: $item. Chi tiết: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('>>> Lỗi khi gọi Supabase để fetch dữ liệu từ bảng service_categories: $e');
      rethrow;
    }
  }
}
