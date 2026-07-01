import 'package:flutter/material.dart';
import '../../models/dashboard_summary_model.dart';
import '../../models/provider_booking_model.dart';
import '../../models/booking_model.dart';
import '../../services/provider/provider_dashboard_service.dart';
import '../../services/provider/provider_bookings_service.dart';
import '../../widgets/provider/provider_booking_card.dart';
import 'provider_bookings_screen.dart';
import 'provider_services_list_screen.dart';
import 'provider_service_form_screen.dart';
import '../../features/profile/profile_menu_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  final ProviderDashboardService _dashboardService = ProviderDashboardService();
  final ProviderBookingsService _bookingsService = ProviderBookingsService();

  bool _isLoading = true;
  String? _errorMessage;
  DashboardSummaryModel? _summary;
  List<ProviderBookingModel> _upcomingBookings = [];
  int _currentTabIndex = 0;

  final GlobalKey<ProviderServicesListScreenState> _servicesListKey =
      GlobalKey();

  // Design Tokens (reused from marketplace & detail screens)
  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);
  static const Color borderColor = Color(0xFFC3C6D7);
  static const Color cardMutedBg = Color(0xFFE5EEFF);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final results = await Future.wait([
        _dashboardService.fetchDashboardSummary(),
        _dashboardService.fetchUpcomingBookings(),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as DashboardSummaryModel;
          _upcomingBookings = results[1] as List<ProviderBookingModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final int index = _upcomingBookings.indexWhere(
      (b) => b.bookingId == bookingId,
    );
    if (index == -1) return;

    final oldBooking = _upcomingBookings[index];
    final updatedBooking = ProviderBookingModel(
      bookingId: oldBooking.bookingId,
      customerName: oldBooking.customerName,
      customerAvatar: oldBooking.customerAvatar,
      serviceTitle: oldBooking.serviceTitle,
      date: oldBooking.date,
      status: newStatus,
      price: oldBooking.price,
      address: oldBooking.address,
      customerNotes: oldBooking.customerNotes,
      requestedAt: oldBooking.requestedAt,
      confirmedAt: oldBooking.confirmedAt,
      completedAt: oldBooking.completedAt,
    );

    // Optimistic UI update
    setState(() {
      _upcomingBookings[index] = updatedBooking;
    });

    try {
      await _bookingsService.updateBookingStatus(bookingId, newStatus);
      // Reload dashboard statistics
      _loadDashboardData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _upcomingBookings[index] = oldBooking;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi cập nhật trạng thái')),
        );
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: primaryColor,
              child: _buildBodyContent(),
            ),
            const ProviderBookingsScreen(),
            ProviderServicesListScreen(key: _servicesListKey),
            
            const ProfileMenuScreen(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProviderServiceFormScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _servicesListKey.currentState?.loadServices();
              _loadDashboardData();
            }
          });
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services_outlined),
            activeIcon: Icon(Icons.design_services),
            label: 'Dịch vụ',
          ),
      
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_errorMessage != null) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Có lỗi xảy ra: $_errorMessage',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDashboardData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBar(),
              const SizedBox(height: 16),
              _buildSummaryStatGrid(),
              const SizedBox(height: 24),
              _buildUpcomingBookingsSection(),
              const SizedBox(height: 80), // FAB spacing
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            radius: 24,
            child: const Text(
              'PV', // Initials fallback
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào,',
                  style: TextStyle(color: bodyText, fontSize: 13),
                ),
                Text(
                  'TechPro VN', // Business name
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: darkText),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: darkText),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _isLoading
          ? _buildSkeletonGrid()
          : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildStatCard(
                  'Lịch hẹn hôm nay',
                  _summary?.todaysBookings.toString() ?? '0',
                ),
                _buildStatCard(
                  'Chờ xác nhận',
                  _summary?.pendingRequests.toString() ?? '0',
                  isValueWarning: true,
                ),
                _buildStatCard(
                  'Doanh thu hôm nay',
                  _summary?.revenueToday ?? '0 đ',
                ),
                _buildStatCard(
                  'Doanh thu tháng',
                  _summary?.monthlyRevenue ?? '0 đ',
                ),
                _buildStatCard(
                  'Đánh giá trung bình',
                  '${_summary?.averageRating.toStringAsFixed(1) ?? '0.0'} ⭐',
                ),
                _buildStatCard(
                  'Tổng việc hoàn thành',
                  _summary?.totalCompletedJobs.toString() ?? '0',
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value, {
    bool isValueWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardMutedBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: bodyText, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isValueWarning ? Colors.orange.shade800 : darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: List.generate(6, (index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 80, height: 12, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Container(width: 50, height: 20, color: Colors.grey.shade300),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUpcomingBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lịch hẹn sắp tới',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              TextButton(
                onPressed: () {
                  _onTabTapped(1); // Navigate to Bookings tab
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          _buildSkeletonList()
        else if (_upcomingBookings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Center(
              child: Text(
                'Không có lịch hẹn nào sắp tới.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _upcomingBookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ProviderBookingCard(
                booking: _upcomingBookings[index],
                onStatusUpdate: (newStatus) => _updateBookingStatus(
                  _upcomingBookings[index].bookingId,
                  newStatus,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 14,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
