// lib/widgets/avatar_builder.dart

import 'package:flutter/material.dart';
import './network_image_fallback.dart';

Widget buildAvatar(String avatarPath, {double radius = 40}) {
  if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEFF4FF),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: NetworkImageWithFallback(
          imageUrl: avatarPath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  return CircleAvatar(
    radius: radius,
    backgroundImage: const AssetImage('assets/default_profile.png'),
  );
}
