// lib/widgets/service/service_detail/service_sticky_action_dock.dart

import 'package:flutter/material.dart';
import '../../../models/service_model.dart';

class ServiceStickyActionDock extends StatelessWidget {
  final ServiceModel? service;
  final VoidCallback onChatPressed;
  final VoidCallback onMapPressed;
  final VoidCallback onBookingPressed;
  final Color primaryColor;
  final Color darkText;

  const ServiceStickyActionDock({
    super.key,
    required this.service,
    required this.onChatPressed,
    required this.onMapPressed,
    required this.onBookingPressed,
    required this.primaryColor,
    required this.darkText,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                onTap: onChatPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.chat_bubble_outline, color: darkText),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onMapPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC3C6D7).withOpacity(0.5),
                    ),
                  ),
                  child: const Icon(Icons.map_outlined, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onBookingPressed,
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
                        'Đặt Ngay',
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
    );
  }
}
