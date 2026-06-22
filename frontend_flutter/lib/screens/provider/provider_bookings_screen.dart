import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/provider_booking_model.dart';
import '../../models/booking_model.dart';
import '../../services/provider/provider_bookings_service.dart';
import '../../utils/booking_status_utils.dart';
import '../../widgets/provider/provider_booking_card.dart';
import 'widgets/booking_detail_sheet.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  final ProviderBookingsService _bookingsService = ProviderBookingsService();
  final ScrollController _scrollController = ScrollController();

  List<ProviderBookingModel> _bookings = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  final List<String> _filters = [
    'All',
    'Pending',
    'Confirmed',
    'In Progress',
    'Completed',
    'Cancelled'
  ];
  String _activeFilter = 'All';

  // Design Tokens
  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color darkText = Color(0xFF0B1C30);

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final results = await _bookingsService.fetchBookings(
        filter: _activeFilter,
        page: _currentPage,
        pageSize: 10,
      );
      if (mounted) {
        setState(() {
          _bookings = results;
          _isLoading = false;
          if (results.length < 10) _hasMore = false;
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

  Future<void> _loadMoreBookings() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final results = await _bookingsService.fetchBookings(
        filter: _activeFilter,
        page: nextPage,
        pageSize: 10,
      );
      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _bookings.addAll(results);
          _isLoadingMore = false;
          if (results.length < 10) _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thêm dữ liệu')),
        );
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final int index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index == -1) return;

    final oldBooking = _bookings[index];
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
      _bookings[index] = updatedBooking;
    });

    try {
      await _bookingsService.updateBookingStatus(bookingId, newStatus);
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() {
          _bookings[index] = oldBooking;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi cập nhật trạng thái')),
        );
      }
    }
  }

  void _showBookingDetail(ProviderBookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => BookingDetailSheet(booking: booking),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'All': return 'Tất cả';
      case 'Pending': return 'Chờ duyệt';
      case 'Confirmed': return 'Đã xác nhận';
      case 'In Progress': return 'Đang thực hiện';
      case 'Completed': return 'Đã hoàn thành';
      case 'Cancelled': return 'Đã hủy';
      default: return filter;
    }
  }

  String _getEmptyMessage() {
    switch (_activeFilter) {
      case 'Pending': return 'Không có yêu cầu chờ xử lý';
      case 'Confirmed': return 'Không có lịch hẹn đã xác nhận';
      case 'In Progress': return 'Không có công việc đang thực hiện';
      case 'Completed': return 'Chưa có công việc nào hoàn thành';
      case 'Cancelled': return 'Không có lịch hẹn bị hủy';
      default: return 'Chưa có lịch hẹn nào';
    }
  }

  BookingStatus? _filterToStatus(String filter) {
    switch (filter) {
      case 'Pending': return BookingStatus.choDuyet;
      case 'Confirmed': return BookingStatus.xacNhan;
      case 'In Progress': return BookingStatus.dangThucHien;
      case 'Completed': return BookingStatus.daHoanThanh;
      case 'Cancelled': return BookingStatus.daHuy;
      default: return null;
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
          'Lịch hẹn',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: darkText),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        color: primaryColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFC3C6D7).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _activeFilter == filter;
          final status = _filterToStatus(filter);

          Color activeBgColor = primaryColor;
          Color activeTextColor = Colors.white;

          if (status != null && isSelected) {
            activeBgColor = BookingStatusUtils.getBackgroundColorForStatus(status);
            activeTextColor = BookingStatusUtils.getTextColorForStatus(status);
            // Ensure contrast if the background is too light
            if (status == BookingStatus.choDuyet) {
              activeBgColor = Colors.orange.shade600;
              activeTextColor = Colors.white;
            } else if (status == BookingStatus.dangThucHien) {
              activeBgColor = primaryColor;
              activeTextColor = Colors.white;
            } else if (status == BookingStatus.daHoanThanh) {
              activeBgColor = Colors.green.shade600;
              activeTextColor = Colors.white;
            }
          }

          // Generate count (mocked dynamically based on current list length for simplicity, 
          // usually this would come from a separate stat query)
          int count = _bookings.where((b) {
            if (filter == 'All') return true;
            return b.status == _filterToStatus(filter);
          }).length;
          
          if (_activeFilter != filter && filter != 'All') {
            count = 0; // Hide count for inactive if not loaded
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeFilter = filter;
              });
              _loadBookings();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeBgColor : const Color(0xFFDCE9FF).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    _getFilterLabel(filter),
                    style: TextStyle(
                      color: isSelected ? activeTextColor : primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (count > 0 && isSelected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: activeTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: _loadBookings,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Group bookings by date
    final groupedBookings = _groupBookingsByDate(_bookings);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: groupedBookings.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == groupedBookings.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final group = groupedBookings[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                group.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
            ...group.bookings.map((booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProviderBookingCard(
                    booking: booking,
                    onTap: () => _showBookingDetail(booking),
                    onStatusUpdate: (newStatus) => _updateBookingStatus(booking.bookingId, newStatus),
                  ),
                )),
          ],
        );
      },
    );
  }

  List<_DateGroup> _groupBookingsByDate(List<ProviderBookingModel> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final Map<String, List<ProviderBookingModel>> map = {};

    for (var b in bookings) {
      if (b.date == null) continue;
      
      final date = DateTime(b.date!.year, b.date!.month, b.date!.day);
      String key;

      if (date == today) {
        key = 'Hôm nay';
      } else if (date == tomorrow) {
        key = 'Ngày mai';
      } else if (date.isBefore(today)) {
        key = 'Trước đó';
      } else {
        key = DateFormat('EEEE, dd MMMM', 'vi_VN').format(b.date!);
      }

      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(b);
    }

    // Sort keys based on predefined order
    final keys = map.keys.toList();
    keys.sort((a, b) {
      if (a == 'Hôm nay') return -1;
      if (b == 'Hôm nay') return 1;
      if (a == 'Ngày mai') return -1;
      if (b == 'Ngày mai') return 1;
      if (a == 'Trước đó') return 1;
      if (b == 'Trước đó') return -1;
      return a.compareTo(b); // Simple string compare for others
    });

    return keys.map((k) => _DateGroup(k, map[k]!)).toList();
  }
}

class _DateGroup {
  final String title;
  final List<ProviderBookingModel> bookings;
  _DateGroup(this.title, this.bookings);
}
