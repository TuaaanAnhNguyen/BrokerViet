// lib/features/booking/booking_history_screen.dart

import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking/booking_service.dart';
import '../../widgets/booking_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  final List<String> _statuses = [
    'Tất cả',
    'Chờ duyệt',
    'Đang thực hiện',
    'Đã hoàn thành',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final currentUserId =
          Supabase.instance.client.auth.currentSession?.user.id;

      if (currentUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = await _bookingService.listBookings(
        customerId: currentUserId,
      );

      if (mounted) {
        setState(() {
          _bookings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print("Lỗi tải danh sách booking: $e");
    }
  }

  BookingStatus? _getEnumFromTab(String tabLabel) {
    switch (tabLabel) {
      case 'Chờ duyệt':
        return BookingStatus.choDuyet;
      case 'Đã hoàn thành':
        return BookingStatus.daHoanThanh;
      case 'Đã hủy':
        return BookingStatus.daHuy;
      default:
        return null;
    }
  }

  void _handleCancelRequest(String bookingId) async {
    try {
      final success = await _bookingService.updateBooking(
        bookingId,
        status: 'CANCELLED',
      );

      if (success && mounted) {
        setState(() {
          _bookings = _bookings.map((b) {
            return b.bookingId == bookingId
                ? b.copyWith(status: BookingStatus.daHuy)
                : b;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy yêu cầu đơn hàng $bookingId thành công.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);

    return DefaultTabController(
      length: _statuses.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Đơn đã mua',
            style: TextStyle(
              color: Color(0xFF0B1C30),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFC3C6D7).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: const Color(0xFF434655),
                indicatorColor: primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: _statuses.map((status) => Tab(text: status)).toList(),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : TabBarView(
                children: _statuses.map((status) {
                  final targetEnum = _getEnumFromTab(status);
                  final filtered = targetEnum == null
                      ? _bookings
                      : _bookings.where((item) => item.status == targetEnum).toList();

                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: _loadInitialData,
                    child: filtered.isEmpty
                        ? CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Text(
                                    'Không tìm thấy đơn hàng nào.',
                                    style: const TextStyle(color: Color(0xFF434655)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return BookingCard(
                                order: item,
                                onCancel: () => _handleCancelRequest(item.bookingId),
                                onRebook: () {},
                                TrackProgress: () {},
                              );
                            },
                          ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}