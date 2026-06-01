// lib/features/main/service_detail_screen.dart

import 'package:flutter/material.dart';
import '../booking/booking_service_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isFavorited = false;
  int _selectedPriceIndex = 1;
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;

  final List<Map<String, String>> _dates = [
    {'day': 'MON', 'num': '12'},
    {'day': 'TUE', 'num': '13'},
    {'day': 'WED', 'num': '14'},
    {'day': 'THU', 'num': '15'},
    {'day': 'FRI', 'num': '16'},
  ];

  final List<String> _times = ['09:00 AM', '11:30 AM', '02:00 PM', '04:30 PM'];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
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
                      onPressed: () =>
                          setState(() => _isFavorited = !_isFavorited),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCHcBPhXY8H0D5jauAP84S4nBpayLARtbYp4RUOLPd48oDy51qHJHTk4A_H7QvF6TKynl8BMbYmUOSLN9J_o2kQvaglso9Evg8KmJCVn_k_DNkKLQi5m0CacctcdLKpmzVYGcQUVV-_Jp7oNDMe7aFqmzfxZP8y0rLpq3kiDoGgkMTVTIQvavqFbTPngo9KQ25Tyg8_uq4UCLa28d2nLsfbBmpw652gHWd7cMZ5gqcZzeMiz53hW6PJS_Wv-ZH3N4qlZuyAFi1ohgHa',
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
              ),

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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF39B8FD,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Hardware',
                                style: TextStyle(
                                  color: Color(0xFF006591),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5EEFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(
                                  color: bodyText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          'Advanced Hardware Diagnostic',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(248 Reviews)',
                              style: TextStyle(color: bodyText, fontSize: 14),
                            ),
                            SizedBox(width: 8),
                            Text('•', style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 8),
                            Text(
                              '1.2k Bookings',
                              style: TextStyle(color: bodyText, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5EEFF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC3C6D7).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCwd61UI8Lox-PUNWYEKXmdGVchlycNnBlxy-ayktMz5e52rYhMBhDMTedR9a1oaoyxI-SG6fFwg8o4XEo0CoVpWNwlDmcUiEpFbHbsTsYYQYKPx__Jqal3TSygcASYv8TP2aJ5lZVN6MzZjoqW1m120QKKP_JP2Y9hXqCWjp24iZTE10leq_hq2-9ydTphNDoBWytek89fFapWaB420N0RU3rzqANgFTVUJQu3K7IOg_S1en-rn0iZ14Q9rfLPUBqh-lHVeJ0W2Olc',
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
                                        const Text(
                                          'Viet Nguyen',
                                          style: TextStyle(
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
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
                                        Icon(
                                          Icons.schedule,
                                          size: 14,
                                          color: bodyText,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '~15m response time',
                                          style: TextStyle(
                                            color: bodyText,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'About this service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Get a complete health check for your enterprise or personal workstation. Our advanced diagnostic includes thermal imaging, voltage stability testing, and deep-level board inspection using industry-standard oscilloscopes and multimeters.',
                          style: TextStyle(
                            color: bodyText,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 4,
                          children: const [
                            _FeatureCheckRow(label: '6-month warranty'),
                            _FeatureCheckRow(label: 'On-site available'),
                            _FeatureCheckRow(label: 'Same-day report'),
                            _FeatureCheckRow(label: 'Certified Lab'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Pricing Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPriceCard(
                          0,
                          'Standard Diagnostic',
                          'General hardware inspection',
                          '\$45.00',
                          primaryColor,
                        ),
                        const SizedBox(height: 12),
                        _buildPriceCard(
                          1,
                          'Deep-Level Circuitry',
                          'Board repair & micro-soldering',
                          '\$120.00',
                          primaryColor,
                          isPopular: true,
                        ),
                        const SizedBox(height: 24),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Schedule',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            Text(
                              'View Calendar',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _dates.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedDateIndex == index;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDateIndex = index),
                                child: Container(
                                  width: 64,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : const Color(0xFFE5EEFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: const Color(
                                              0xFFC3C6D7,
                                            ).withOpacity(0.5),
                                          ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _dates[index]['day']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : bodyText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dates[index]['num']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : darkText,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _times.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedTimeIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(_times[index]),
                                  selected: isSelected,
                                  onSelected: (val) => setState(
                                    () => _selectedTimeIndex = index,
                                  ),
                                  selectedColor: primaryColor,
                                  backgroundColor: const Color(0xFFE5EEFF),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : darkText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? primaryColor
                                        : const Color(
                                            0xFFC3C6D7,
                                          ).withOpacity(0.5),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 7. Inline Customer Reviews Box block
                        const Text(
                          'Reviews',
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
                                  imageUrl:
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBoqeaz1N4IfWAVsvvV_d6Itb6mJnzOSjkSBnVH5Ek1AXXd2CfrK_Wu-CidsO4tBAcM_riWGRKXXb1dtoF7SMwVLDo3TGKdNP8SDUWT52Y5NaVHQWbwKT9ExlgBDZPKTqO9aBKXykk61o1e87TdwsszLDf0IR7sSkfs64glK8QU7rPKzDIYRrU2T3qnoV3fyRvEnK4fYDe2ySL14Ao6z-2JBsdsHE_0Gh1txiRE60j4iBo8Il3eg5_W4FOaD6zWpxfPYYVWgOd_SS9k',
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Aria Smith',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (_) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '"Highly professional. My laptop wouldn\'t turn on, and Viet diagnosed the blown capacitor in 30 minutes."',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: bodyText,
                          ),
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
                            'Show all reviews',
                            style: TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                        ), // Creates safety buffer for floating bar layout
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 8. Sticky Action Purchase Dock Drawer Block
          Positioned(
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
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 1. Gather the selected data from the state
                          final selectedPackage = _selectedPriceIndex == 0
                              ? 'Standard Diagnostic'
                              : 'Deep-Level Circuitry';
                          final selectedPrice = _selectedPriceIndex == 0
                              ? '\$45.00'
                              : '\$120.00';
                          final selectedDate =
                              '${_dates[_selectedDateIndex]['day']} ${_dates[_selectedDateIndex]['num']}';
                          final selectedTime = _times[_selectedTimeIndex];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingScreen(
                                serviceTitle: 'Advanced Hardware Diagnostic',
                                providerName: 'Viet Nguyen',
                                packageName: selectedPackage,
                                price: selectedPrice,
                                date: selectedDate,
                                time: selectedTime,
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
                              'Book Now',
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
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    int index,
    String title,
    String subtitle,
    String price,
    Color activeColor, {
    bool isPopular = false,
  }) {
    final isSelected = _selectedPriceIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriceIndex = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFC3C6D7),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF434655),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
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
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'POPULAR',
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

// Global safe Image widget fallback utility
class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // If the URL fails to resolve or breaks, gracefully swap to a placeholder icon
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE5EEFF),
          child: const Icon(Icons.person, color: Color(0xFF004AC6)),
        );
      },
      // Optional loading indicator spinner while downloading the asset image frame
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFF8F9FF),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
