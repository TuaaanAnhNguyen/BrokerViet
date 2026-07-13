import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/service_model.dart';
import '../../../services/provider/provider_services_service.dart';
import '../../../services/voucher_service.dart';

class VoucherFormScreen extends StatefulWidget {
  const VoucherFormScreen({super.key});

  @override
  State<VoucherFormScreen> createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends State<VoucherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final VoucherService _voucherService = VoucherService();
  final ProviderServicesService _servicesService = ProviderServicesService();

  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _minOrderController = TextEditingController(text: '0');
  final _usageLimitController = TextEditingController();
  final _usageLimitPerUserController = TextEditingController(text: '1');

  String _discountType = 'PERCENTAGE';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _applyToAllServices = true;
  List<ServiceModel> _myServices = [];
  final Set<String> _selectedServiceIds = {};
  bool _isLoadingServices = true;
  bool _isSubmitting = false;

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);
  static const Color borderColor = Color(0xFFC3C6D7);

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _maxDiscountController.dispose();
    _minOrderController.dispose();
    _usageLimitController.dispose();
    _usageLimitPerUserController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final services = await _servicesService.fetchMyServices();
      if (mounted) {
        setState(() {
          _myServices = services;
          _isLoadingServices = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingServices = false);
      }
    }
  }

  bool get _canSubmit {
    if (_startDate == null || _endDate == null) return false;
    if (!_endDate!.isAfter(_startDate!)) return false;
    if (!_applyToAllServices && _selectedServiceIds.isEmpty) return false;
    return true;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || !_formKey.currentState!.validate()) return;

    final providerId = Supabase.instance.client.auth.currentUser?.id;
    if (providerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _voucherService.createVoucher(
        providerId: providerId,
        code: _codeController.text.trim().toUpperCase(),
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text.trim()),
        startDate: _startDate!,
        endDate: _endDate!,
        maxDiscountAmount: _discountType == 'PERCENTAGE' &&
                _maxDiscountController.text.trim().isNotEmpty
            ? double.parse(_maxDiscountController.text.trim())
            : null,
        minOrderValue: double.tryParse(_minOrderController.text.trim()) ?? 0,
        usageLimit: _usageLimitController.text.trim().isEmpty
            ? null
            : int.parse(_usageLimitController.text.trim()),
        usageLimitPerUser:
            int.parse(_usageLimitPerUserController.text.trim()),
        applicableServiceIds:
            _applyToAllServices ? null : _selectedServiceIds.toList(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on VoucherException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tạo mã giảm giá')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tạo mã giảm giá',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _codeController,
              label: 'Mã voucher',
              hint: 'VD: SUMMER2026',
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                final upper = value.toUpperCase();
                if (upper != value) {
                  _codeController.value = _codeController.value.copyWith(
                    text: upper,
                    selection: TextSelection.collapsed(offset: upper.length),
                  );
                }
              },
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Nhập mã voucher' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Loại giảm giá',
              style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'PERCENTAGE', label: Text('%')),
                ButtonSegment(value: 'FIXED_AMOUNT', label: Text('VNĐ')),
              ],
              selected: {_discountType},
              onSelectionChanged: (selection) {
                setState(() => _discountType = selection.first);
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _discountValueController,
              label: 'Giá trị giảm',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nhập giá trị giảm';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Giá trị phải lớn hơn 0';
                }
                if (_discountType == 'PERCENTAGE' && parsed > 100) {
                  return 'Phần trăm không được vượt quá 100';
                }
                return null;
              },
            ),
            if (_discountType == 'PERCENTAGE') ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _maxDiscountController,
                label: 'Giảm tối đa (tùy chọn)',
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            _buildTextField(
              controller: _minOrderController,
              label: 'Đơn hàng tối thiểu',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _usageLimitController,
              label: 'Tổng lượt dùng (để trống = không giới hạn)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _usageLimitPerUserController,
              label: 'Lượt dùng mỗi khách',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nhập lượt dùng mỗi khách';
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Phải lớn hơn 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDatePickerRow(
              label: 'Ngày bắt đầu',
              date: _startDate,
              onTap: () => _pickDate(isStart: true),
            ),
            const SizedBox(height: 12),
            _buildDatePickerRow(
              label: 'Ngày kết thúc',
              date: _endDate,
              onTap: () => _pickDate(isStart: false),
              validatorMessage: _startDate != null &&
                      _endDate != null &&
                      !_endDate!.isAfter(_startDate!)
                  ? 'Ngày kết thúc phải sau ngày bắt đầu'
                  : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Tất cả dịch vụ',
                style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
              ),
              value: _applyToAllServices,
              activeThumbColor: primaryColor,
              onChanged: (value) {
                setState(() {
                  _applyToAllServices = value;
                  if (value) _selectedServiceIds.clear();
                });
              },
            ),
            if (!_applyToAllServices) ...[
              if (_isLoadingServices)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_myServices.isEmpty)
                const Text(
                  'Bạn chưa có dịch vụ nào để áp dụng voucher.',
                  style: TextStyle(color: bodyText),
                )
              else
                ..._myServices.map((service) {
                  final serviceId = service.id;
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(service.title),
                    subtitle: Text(service.price),
                    value: _selectedServiceIds.contains(serviceId),
                    activeColor: primaryColor,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedServiceIds.add(serviceId);
                        } else {
                          _selectedServiceIds.remove(serviceId);
                        }
                      });
                    },
                  );
                }),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_isSubmitting || !_canSubmit) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Tạo mã giảm giá',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildDatePickerRow({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    String? validatorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: validatorMessage != null ? Colors.red : borderColor,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                      : 'Chọn ngày',
                  style: TextStyle(
                    color: date != null ? darkText : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: primaryColor, size: 20),
              ],
            ),
          ),
        ),
        if (validatorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              validatorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
