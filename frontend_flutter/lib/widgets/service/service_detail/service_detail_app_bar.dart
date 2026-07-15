import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../widgets/network_image_fallback.dart';

class ServiceDetailAppBar extends StatelessWidget {
  final ServiceModel? service;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;
  final Color primaryColor;
  final Color surfaceColor;
  final Color darkText;

  const ServiceDetailAppBar({
    super.key,
    required this.service,
    required this.isFavorited,
    required this.onFavoriteToggle,
    required this.primaryColor,
    required this.surfaceColor,
    required this.darkText,
  });

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : darkText,
            ),
            onPressed: onFavoriteToggle,
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWithFallback(
              imageUrl: service?.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [surfaceColor, Colors.transparent],
                  stops: const [0.0, 0.3],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
