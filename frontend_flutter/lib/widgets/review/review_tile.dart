// lib/widgets/review/review_tile.dart

import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../avatar_builder.dart';

class ReviewTile extends StatelessWidget {
  final ReviewModel review;
  final Color darkText;
  final Color bodyText;
  final VoidCallback? onEditPressed;

  const ReviewTile({
    super.key,
    required this.review,
    required this.darkText,
    required this.bodyText,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            buildAvatar(review.userAvatar, radius: 16),
            const SizedBox(width: 8),

            Row(
              children: [
                Text(
                  review.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkText,
                  ),
                ),
                if (onEditPressed != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEditPressed,
                    child: const Icon(Icons.edit, size: 14, color: Colors.blue),
                  ),
                ],
              ],
            ),

            const Spacer(),

            Row(
              children: List.generate(
                5,
                (starIndex) => Icon(
                  Icons.star,
                  color: starIndex < review.rating
                      ? Colors.amber
                      : Colors.grey[300],
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        Text(
          review.comment,
          style: TextStyle(
            color: bodyText,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
