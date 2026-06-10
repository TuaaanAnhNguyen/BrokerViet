// lib/widgets/auth/auth_header.dart

import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.build_circle_outlined,
          size: 80,
          color: Colors.blue,
        ),
        SizedBox(height: 16),
        Text(
          'BrokerViet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}