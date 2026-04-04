// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditRoutineHeader extends StatelessWidget {
  final String clientName;
  final String imageUrl;

  const EditRoutineHeader({
    super.key,
    required this.clientName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Back Navigation & Label
          GestureDetector(
            onTap: () => Get.back(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: Color(0xFF00B171), // Green Arrow
                ),
                const SizedBox(width: 8),
                Text(
                  'CLIENT MANAGEMENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF00B171), // Green Text
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Title
          const Text(
            'Edit Routine',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 16),

          // Client Info (Avatar + Name)
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: imageUrl.startsWith('http') ? NetworkImage(imageUrl) as ImageProvider : AssetImage(imageUrl),
              ),
              const SizedBox(width: 12),
              Text(
                clientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}