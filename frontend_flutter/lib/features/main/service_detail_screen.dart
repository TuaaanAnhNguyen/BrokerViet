import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // CHANGE: Imported Supabase client
import '../../widgets/network_image_fallback.dart';
import '../../models/service_model.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import '../booking/booking_service_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServiceMarketplaceService _marketplaceService =
      ServiceMarketplaceService();

  // CHANGE: Get reference to global Supabase client instance
  final SupabaseClient supabase = Supabase.instance.client;

  ServiceModel? _service;
  bool _isLoading = true;
  String? _errorMessage;

  bool _isFavorited = false;
  int _selectedPriceIndex = 0;

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);

  @override
  void initState() {
    super.initState();
    _loadServiceDetail();
  }

  Future<void> _loadServiceDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final service = await _marketplaceService.fetchServiceDetail(
        widget.serviceId,
      );
      if (mounted) {
        setState(() {
          _service = service;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('>>> Lỗi load service detail: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải thông tin dịch vụ.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FF),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: surfaceColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadServiceDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTagsSection(),
                        const SizedBox(height: 12),
                        _buildTitleSection(),
                        const SizedBox(height: 24),
                        _buildProviderCard(),
                        const SizedBox(height: 24),
                        _buildDescriptionSection(),
                        const SizedBox(height: 24),
                        _buildPricePackagesSection(),
                        const SizedBox(height: 24),
                        _buildReviewsSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildStickyActionDock(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: darkText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.share, color: darkText),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : darkText,
            ),
            onPressed: () => setState(() => _isFavorited = !_isFavorited),
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWithFallback(
              imageUrl: _service?.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [surfaceColor, Colors.transparent],
                  stops: [0.0, 0.3],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    final categoryName = _service?.categoryName;
    return Row(
      children: [
        if (categoryName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF39B8FD).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              categoryName,
              style: const TextStyle(
                color: Color(0xFF006591),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _service?.title ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              _service?.rating.toStringAsFixed(1) ?? '0.0',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            const Text(
              '1.2k Lượt đặt',
              style: TextStyle(color: bodyText, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: const NetworkImageWithFallback(
              imageUrl: '',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _service?.providerUsername ?? 'Nhà cung cấp',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: bodyText),
                    SizedBox(width: 4),
                    Text(
                      'Phản hồi ~15 phút',
                      style: TextStyle(color: bodyText, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Về dịch vụ này',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _service?.subtitle ?? '',
          style: const TextStyle(color: bodyText, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 4,
          children: const [
            _FeatureCheckRow(label: 'Bảo hành 6 tháng'),
            _FeatureCheckRow(label: 'Hỗ trợ tại nhà'),
            _FeatureCheckRow(label: 'Báo cáo trong ngày'),
            _FeatureCheckRow(label: 'Kỹ thuật viên chứng chỉ'),
          ],
        ),
      ],
    );
  }

  Widget _buildPricePackagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gói Dịch Vụ & Giá',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        _buildPriceCard(
          0,
          'Chẩn đoán Cơ bản',
          'Sửa laptop, sửa PC, diệt virus cơ bản',
          _service?.price ?? '450.000 VND',
          isPopular: false,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPriceCard(
    int index,
    String title,
    String subtitle,
    String price, {
    required bool isPopular,
  }) {
    final isSelected = _selectedPriceIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriceIndex = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFC3C6D7),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: bodyText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            if (isPopular)
              Positioned(
                top: -28,
                right: -16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'PHỔ BIẾN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const NetworkImageWithFallback(
                  imageUrl: '',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Minh Thư',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              children: List.generate(
                5,
                (_) => const Icon(Icons.star, color: Colors.amber, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '"Làm việc rất chuyên nghiệp. Máy mình không lên nguồn, anh kỹ thuật viên tìm ra lỗi hỏng tụ điện và sửa xong chỉ trong 30 phút."',
          style: TextStyle(fontStyle: FontStyle.italic, color: bodyText),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: Color(0xFFC3C6D7)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Xem tất cả đánh giá',
            style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyActionDock() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: const Border(
            top: BorderSide(color: Color(0xFFC3C6D7), width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: darkText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // CHANGE: Get current logged-in user id for dynamic customer tracking
                    final currentCustomerId =
                        supabase.auth.currentUser?.id ?? '';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          // CHANGE: Cleaned up conflict block, mapped UI metadata dynamically
                          serviceTitle: _service?.title ?? 'Chưa có tiêu đề',
                          providerName:
                              _service?.providerUsername ?? 'Nhà cung cấp',
                          packageName: _selectedPriceIndex == 0
                              ? 'Chẩn đoán Cơ bản'
                              : 'Sửa chữa Chuyên sâu',

                          // CHANGE: Added dynamic relational references instead of hardcoded IDs
                          serviceId: _service?.id ?? '',
                          providerId: _service?.providerId ?? '',
                          customerId: currentCustomerId,

                          // CHANGE: Used safe parsed int value from model instead of regex replacement logic
                          totalPrice: _service?.priceValue.toInt() ?? 0,
                          scheduledAt: DateTime.now(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đặt Lịch Ngay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCheckRow extends StatelessWidget {
  final String label;
  const _FeatureCheckRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF004AC6), size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0B1C30)),
          ),
        ),
      ],
    );
  }
}
