import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_model.dart';

class ProviderServicesService {
  final _supabase = Supabase.instance.client;

  Future<List<ServiceModel>> fetchMyServices() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Vui lòng đăng nhập');

      final response = await _supabase
          .from('services')
          .select('*, service_categories(name)')
          .eq('provider_id', userId);

      return (response as List).map((item) {
        return ServiceModel.fromJson(item);
      }).toList();
    } catch (e) {
      print('>>> Lỗi khi fetch my services: $e');
      rethrow;
    }
  }

  Future<String?> uploadServiceImage(File imageFile) async {
    try {
      final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = fileName;

      await _supabase.storage
          .from('service_images')
          .upload(filePath, imageFile);

      return _supabase.storage.from('service_images').getPublicUrl(filePath);
    } catch (e) {
      print('>>> Lỗi khi upload ảnh dịch vụ: $e');
      return null;
    }
  }

  Future<void> addService(Map<String, dynamic> serviceData, File? imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Vui lòng đăng nhập');

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadServiceImage(imageFile);
      }

      final data = {
        ...serviceData,
        'provider_id': userId,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      await _supabase.from('services').insert(data);
    } catch (e) {
      print('>>> Lỗi khi thêm dịch vụ: $e');
      rethrow;
    }
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> serviceData, File? imageFile) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadServiceImage(imageFile);
      }

      final data = {
        ...serviceData,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      await _supabase.from('services').update(data).eq('service_id', serviceId);
    } catch (e) {
      print('>>> Lỗi khi cập nhật dịch vụ: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _supabase.from('services').delete().eq('service_id', serviceId);
    } catch (e) {
      print('>>> Lỗi khi xóa dịch vụ: $e');
      rethrow;
    }
  }
}
