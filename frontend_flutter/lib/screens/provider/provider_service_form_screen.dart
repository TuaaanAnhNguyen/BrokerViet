import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/service_model.dart';
import '../../models/service_category_model.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import '../../services/provider/provider_services_service.dart';

class ProviderServiceFormScreen extends StatefulWidget {
  final ServiceModel? service;

  const ProviderServiceFormScreen({super.key, this.service});

  @override
  State<ProviderServiceFormScreen> createState() => _ProviderServiceFormScreenState();
}

class _ProviderServiceFormScreenState extends State<ProviderServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String? _selectedCategoryId;
  List<ServiceCategoryModel> _categories = [];
  File? _imageFile;
  bool _isSubmitting = false;

  final ProviderServicesService _providerService = ProviderServicesService();
  final ServiceMarketplaceService _marketplaceService = ServiceMarketplaceService();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _titleController.text = widget.service!.title;
      _descriptionController.text = widget.service!.subtitle;
      _priceController.text = widget.service!.priceValue.toInt().toString();
      _selectedCategoryId = widget.service!.categoryId;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _marketplaceService.fetchServiceCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'service_cat_id': _selectedCategoryId,
      };

      if (widget.service == null) {
        await _providerService.addService(data, _imageFile);
      } else {
        await _providerService.updateService(widget.service!.id, data, _imageFile);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service == null ? 'Thêm dịch vụ' : 'Sửa dịch vụ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá (VND)'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập giá' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.serviceCatId,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
                validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : widget.service?.imageUrl != null && widget.service!.imageUrl != 'assets/no_icon_placeholder.png'
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(widget.service!.imageUrl!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Chọn ảnh dịch vụ', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.service == null ? 'THÊM DỊCH VỤ' : 'CẬP NHẬT',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
