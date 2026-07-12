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

  Future<void> loadServices({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _isLoading = true);
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
          return ServiceCard(
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
          );
        },
      ),
    );
  }
}
