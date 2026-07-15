// lib/widgets/map/my_location_button.dart

import 'package:flutter/material.dart';

class MyLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MyLocationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.my_location_rounded),
      tooltip: 'Vị trí của tôi',
      onPressed: onPressed,
    );
  }
}
