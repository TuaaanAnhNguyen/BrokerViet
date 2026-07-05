import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_model.dart';
import '../../models/service_category_model.dart';
import '../../models/review_model.dart';
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

    // Gộp tất cả tham số vào một Map và truyền trực tiếp giá trị thực tế (hoặc null)
    // Điều này giúp Postgres nhận diện đúng cấu trúc hàm giống như khi bạn test thủ công
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
      print(
        '>>> Lỗi khi gọi Supabase để fetch dữ liệu từ bảng service_categories: $e',
      );
      rethrow;
    }
  }

  Future<ServiceModel> fetchServiceDetail(String serviceId) async {
    try {
      final response = await _supabase.rpc(
        'get_service_detail',
        params: {'p_service_id': serviceId},
      );

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('Không tìm thấy service với ID: $serviceId');
      }

      final item = (response as List).first as Map<String, dynamic>;
      return ServiceModel.fromJson(item);
    } catch (e) {
      print('>>> Lỗi khi gọi RPC get_service_detail: $e');
      rethrow;
    }
  }

  // ── REVIEWS ───────────────────────────────────────────────
  Future<List<ReviewModel>> fetchServiceReviews(String serviceId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, profiles(username, avatar_url)')
          .eq('service_id', serviceId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => ReviewModel.fromMap(json)).toList();
    } catch (e) {
      print('>>> Lỗi khi fetch reviews: $e');
      return [];
    }
  }

  Future<bool> checkUserPurchasedService(String serviceId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('bookings')
          .select('booking_id')
          .eq('customer_id', userId)
          .eq('service_id', serviceId)
          .eq('status', 'COMPLETED')
          .limit(1)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('>>> Lỗi khi check purchase: $e');
      return false;
    }
  }

  Future<void> submitReview({
    required String serviceId,
    required int rating,
    required String comment,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Bạn cần đăng nhập để đánh giá');

      final response = await _supabase.functions.invoke(
        'manage-review',
        body: {
          'action': 'create',
          'service_id': serviceId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.status != 200) {
        final err = (response.data as Map?)?['error'] ?? 'Unknown error';
        throw Exception('Lỗi khi gửi đánh giá: $err');
      }
    } catch (e) {
      print('>>> Lỗi khi gửi review qua Edge Function: $e');
      rethrow;
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Bạn cần đăng nhập');

      final response = await _supabase.functions.invoke(
        'manage-review',
        body: {
          'action': 'update',
          'review_id': reviewId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.status != 200) {
        final err = (response.data as Map?)?['error'] ?? 'Unknown error';
        throw Exception('Lỗi khi cập nhật đánh giá: $err');
      }
    } catch (e) {
      print('>>> Lỗi khi cập nhật review qua Edge Function: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Bạn cần đăng nhập');

      final response = await _supabase.functions.invoke(
        'manage-review',
        body: {
          'action': 'delete',
          'review_id': reviewId,
          'user_id': userId,
        },
      );

      if (response.status != 200) {
        final err = (response.data as Map?)?['error'] ?? 'Unknown error';
        throw Exception('Lỗi khi xóa đánh giá: $err');
      }
    } catch (e) {
      print('>>> Lỗi khi xóa review qua Edge Function: $e');
      rethrow;
    }
  }
}
