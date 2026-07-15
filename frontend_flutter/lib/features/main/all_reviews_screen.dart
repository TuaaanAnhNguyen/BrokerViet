// lib/features/main/all_reviews_screen.dart

import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../widgets/review/review_tile.dart';

class AllReviewsScreen extends StatelessWidget {
  final List<ReviewModel> reviews;
  final String serviceTitle;

  const AllReviewsScreen({
    super.key,
    required this.reviews,
    required this.serviceTitle,
  });

  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text(
          'Đánh giá - $serviceTitle',
          style: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: reviews.isEmpty
          ? const Center(
              child: Text(
                'Chưa có đánh giá nào.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                return ReviewTile(
                  review: reviews[index],
                  darkText: darkText,
                  bodyText: bodyText,
                );
              },
            ),
    );
  }
}
