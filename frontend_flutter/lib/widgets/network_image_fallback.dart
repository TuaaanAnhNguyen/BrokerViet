// lib/widgets/network_image_fallback.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  bool _isValidNetworkUrl(String url) {
    final cleanUrl = url.trim().toLowerCase();
    if (cleanUrl.isEmpty || cleanUrl == 'null') return false;
    return cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final String trimmedUrl = imageUrl.trim();

    if (trimmedUrl.startsWith('assets/')) {
      return _buildAssetPlaceholder(customPath: trimmedUrl);
    }

    if (!_isValidNetworkUrl(trimmedUrl)) {
      return _buildAssetPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: trimmedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF8F9FF),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF004AC6),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildAssetPlaceholder(),
    );
  }

  Widget _buildAssetPlaceholder({String? customPath}) {
    return Image.asset(
      customPath ?? 'assets/no_icon_placeholder.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE5EEFF),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_rounded,
              color: Color(0xFF004AC6),
              size: 24,
            ),
          ),
        );
      },
    );
  }
}