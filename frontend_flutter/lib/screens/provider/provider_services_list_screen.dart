import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/provider/provider_services_service.dart';
import '../../widgets/service/service_card.dart';
import 'provider_service_form_screen.dart';

class ProviderServicesListScreen extends StatefulWidget {
  const ProviderServicesListScreen({super.key});

  @override
  State<ProviderServicesListScreen> createState() => ProviderServicesListScreenState();
}

class ProviderServicesListScreenState extends State<ProviderServicesListScreen> {
  final ProviderServicesService _servicesService = ProviderServicesService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final services = await _servicesService.fetchMyServices();
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách: $e')),
        );
      }
    }
  }

  void _deleteService(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa dịch vụ này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _servicesService.deleteService(id);
        loadServices();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa dịch vụ: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_services.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadServices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(child: Text('Bạn chưa có dịch vụ nào.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return Stack(
            children: [
              ServiceCard(
                service: service,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderServiceFormScreen(service: service),
                    ),
                  ).then((result) {
                    if (result == true) loadServices();
                  });
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProviderServiceFormScreen(service: service),
                          ),
                        ).then((result) {
                          if (result == true) loadServices();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteService(service.id),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
