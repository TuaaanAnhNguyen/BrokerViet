// lib/features/booking/booking_service_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/booking/booking_service.dart';
import '../../services/payment/vnpay_service.dart';
import '../../services/voucher_service.dart';
import '../../services/map-location/location_service.dart';
import '../../widgets/payment/vietqr_payment.dart';
import '../../widgets/voucher/voucher_input_field.dart';

import '../../widgets/booking/booking_header_card.dart';
import '../../widgets/booking/booking_schedule_tile.dart';
import '../../widgets/booking/booking_address_input.dart';
import '../../widgets/booking/booking_notes_input.dart';
import '../../widgets/booking/payment_method_selector.dart';
import '../../widgets/booking/invoice_breakdown_card.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String? providerName;
  final String serviceTitle;
  final String packageName;
  final String customerId;
  final String providerId;
  final String? serviceType;
  final DateTime scheduledAt;
  final int totalPrice;
  final String? serviceImageUrl;

  const BookingScreen({
    super.key,
    required this.serviceId,
    this.providerName,
    required this.serviceTitle,
    required this.packageName,
    required this.customerId,
    required this.providerId,
    required this.scheduledAt,
    required this.totalPrice,
    this.serviceType,
    this.serviceImageUrl,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final VNPayService _vnPayService = VNPayService();

  // Khởi tạo LocationService
  final LocationService _locationService = LocationService();

  late TextEditingController _addressController;
  final _notesController = TextEditingController();

  int _selectedPaymentMethod = 0; // 0: VietQR, 2: Tiền mặt, 3: VNPAY
  bool _isSubmitting = false;
  bool _isLoadingLocation = false; // Flag kiểm soát vòng quay Loading ở Button
  String? _appliedVoucherCode;
  double _discountAmount = 0;
  late double _finalPrice;

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.totalPrice.toDouble();
    // Bắt đầu bằng chuỗi rỗng thay vì mock data, hoặc tự động trigger load
    _addressController = TextEditingController(text: "");

    // Tự động load vị trí mặc định ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFetchCurrentLocation();
    });
  }

  // Hàm xử lý lấy địa chỉ thực tế từ Edge Function hoặc profile
  Future<void> _handleFetchCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      print(">>> Fetching real-time PostGIS/GPS location...");
      // Cách 1: Ưu tiên lấy vị trí GPS/IP hiện tại của thiết bị qua hàm bạn đã viết
      final currentLoc = await _locationService.getMyLocation();
      if (currentLoc.address != null && currentLoc.address!.isNotEmpty) {
        _addressController.text = currentLoc.address!;
        return;
      }

      // Cách 2: Fallback tìm trong DB public.profiles nếu hàm trên không trả về text
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        print(
          ">>> Fallback: Fetching saved address from public.profiles DB...",
        );
        final response = await client.functions.invoke('fetch-profile');
        if (response.status == 200 && response.data != null) {
          final dataMap = response.data as Map<String, dynamic>;
          final profileData = dataMap['profile'] as Map<String, dynamic>?;

          final savedAddress =
              profileData?['address'] ?? profileData?['location_text'];
          if (savedAddress != null && savedAddress.toString().isNotEmpty) {
            _addressController.text = savedAddress.toString();
            return;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy dữ liệu vị trí mặc định."),
          ),
        );
      }
    } catch (e) {
      print(">>> Error fetching location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải vị trí: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _onVoucherApplied(
    String? voucherCode,
    double discountAmount,
    double finalPrice,
  ) {
    setState(() {
      _appliedVoucherCode = voucherCode;
      _discountAmount = discountAmount;
      _finalPrice = finalPrice;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _selectedPaymentLabel() {
    switch (_selectedPaymentMethod) {
      case 2:
        return 'Tiền mặt sau dịch vụ';
      case 3:
        return 'Cổng thanh toán VNPAY';
      default:
        return 'Chuyển khoản Online (VietQR)';
    }
  }

  void _processBookingAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final paymentLabel = _selectedPaymentLabel();
    debugPrint('Payment method selected: $paymentLabel');

    final int finalCalculatedPrice = _finalPrice.round();

    try {
      String? confirmedBookingId;

      final bookingResult = await _bookingService.createBooking(
        serviceId: widget.serviceId,
        customerId: widget.customerId,
        providerId: widget.providerId,
        totalPrice: finalCalculatedPrice,
        scheduledAt: widget.scheduledAt,
        serviceType: widget.serviceType,
        voucherCode: _appliedVoucherCode,
      );

      confirmedBookingId = (bookingResult['booking_id'] != null)
          ? bookingResult['booking_id'].toString()
          : await _bookingService.getLatestBookingId(widget.customerId);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (confirmedBookingId == null || confirmedBookingId.isEmpty) {
        throw Exception("Could not retrieve booking ID after creation.");
      }

      final String trackingMemo = confirmedBookingId
          .substring(0, 8)
          .toUpperCase();
      final rootNavigator = Navigator.of(context);

      if (_selectedPaymentMethod == 0) {
        // VietQR Flow
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Thanh toán đơn hàng')),
              body: Center(
                child: VietQRPaymentWidget(
                  memo: trackingMemo,
                  paymentAmount: finalCalculatedPrice,
                  providerBankCode: 'bidv',
                  providerBankAccount: '8821165401',
                  onSimulateSuccess: () {
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Row(
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'Giả lập thanh toán thành công',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Hệ thống ghi nhận thanh toán thành công cho dịch vụ ${widget.serviceTitle} theo hình thức mã định danh VietQR ($trackingMemo).',
                          style: const TextStyle(color: Color(0xFF434655)),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              rootNavigator.popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004AC6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Về Trang Chủ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      } else if (_selectedPaymentMethod == 3) {
        // VNPay Flow
        debugPrint(
          'Sending to VNPay: bookingId=$confirmedBookingId, amount=$finalCalculatedPrice',
        );
        final paymentUrl = await _vnPayService.createPaymentUrl(
          bookingId: confirmedBookingId,
          amount: finalCalculatedPrice,
          orderInfo: 'Thanh toan don hang ${widget.serviceTitle}',
        );
        if (paymentUrl != null) {
          await _vnPayService.openVNPay(paymentUrl);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể khởi tạo thanh toán VNPAY.'),
              ),
            );
          }
        }
      } else {
        // Cash Flow (Tiền mặt sau dịch vụ)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF004AC6)),
                SizedBox(width: 8),
                Text(
                  'Đặt lịch thành công',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              'Lịch hẹn dịch vụ ${widget.serviceTitle} vào ngày ${DateFormat('dd/MM/yyyy HH:mm').format(widget.scheduledAt)} đã được ghi nhận thành công theo hình thức $paymentLabel.',
              style: const TextStyle(color: Color(0xFF434655)),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  rootNavigator.popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Về Trang Chủ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      debugPrint("Booking Execution Error: $e");
      final message = e is VoucherException
          ? e.message
          : 'Không thể lưu đơn đặt lịch. Vui lòng thử lại sau.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đặt',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    BookingHeaderCard(
                      serviceTitle: widget.serviceTitle,
                      packageName: widget.packageName,
                      serviceImageUrl: widget.serviceImageUrl,
                    ),
                    const SizedBox(height: 20),

                    BookingScheduleTile(scheduledAt: widget.scheduledAt),
                    const SizedBox(height: 20),

                    BookingAddressInput(
                      controller: _addressController,
                      isLoading: _isLoadingLocation,
                      onFetchCurrentLocation: _handleFetchCurrentLocation,
                    ),
                    const SizedBox(height: 20),

                    BookingNotesInput(controller: _notesController),
                    const SizedBox(height: 20),

                    PaymentMethodSelector(
                      selectedPaymentMethod: _selectedPaymentMethod,
                      onMethodChanged: (methodIndex) {
                        setState(() => _selectedPaymentMethod = methodIndex);
                      },
                    ),
                    const SizedBox(height: 20),

                    VoucherInputField(
                      providerId: widget.providerId,
                      customerId: widget.customerId,
                      serviceId: widget.serviceId,
                      orderValue: widget.totalPrice.toDouble(),
                      onVoucherApplied: _onVoucherApplied,
                    ),
                    const SizedBox(height: 20),

                    InvoiceBreakdownCard(
                      packageName: widget.packageName,
                      serviceFee: widget.totalPrice.toDouble(),
                      discountAmount: _discountAmount,
                      totalAmount: _finalPrice,
                      appliedVoucherCode: _appliedVoucherCode,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Giá thanh toán cuối',
                              style: TextStyle(fontSize: 12, color: bodyText),
                            ),
                            Text(
                              _formatCurrency(_finalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: bodyText,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Thanh toán bảo mật',
                              style: TextStyle(fontSize: 12, color: bodyText),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _processBookingAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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
                              'Xác nhận đặt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 11, color: bodyText),
                        children: [
                          TextSpan(
                            text:
                                'Bằng việc nhấn nút "Xác nhận đặt", bạn đồng ý với ',
                          ),
                          TextSpan(
                            text: 'Điều khoản dịch vụ',
                            style: TextStyle(
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' của chúng tôi.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
