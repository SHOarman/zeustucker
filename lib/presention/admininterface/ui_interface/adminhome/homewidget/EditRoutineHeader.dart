import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class EditRoutineHeader extends StatelessWidget {
  final String clientName;
  final String imageUrl;
  final bool isCreateMode;

  const EditRoutineHeader({
    super.key,
    required this.clientName,
    required this.imageUrl,
    this.isCreateMode = false,
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
          Text(
            isCreateMode ? 'Create Routine' : 'Edit Routine',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 16),

          // Client Info (Avatar + Name)
          Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: ClipOval(
                  child: _buildHeaderAvatar(imageUrl),
                ),
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

  Widget _buildHeaderAvatar(String url) {
    const defaultAsset = 'assets/image/David Park.png';

    if (url.isEmpty || url == 'string' || url == 'null') {
      return Image.asset(defaultAsset, width: 36, height: 36, fit: BoxFit.cover);
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final altUrl = url.contains(':8000') ? url.replaceAll(':8000', ':8004') : url.replaceAll(':8004', ':8000');
          return Image.network(
            altUrl,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, width: 36, height: 36, fit: BoxFit.cover),
          );
        },
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, width: 36, height: 36, fit: BoxFit.cover),
      );
    }

    try {
      final String cleanBase64 = url.startsWith('data:image') && url.contains('base64,')
          ? url.split('base64,').last
          : url;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, width: 36, height: 36, fit: BoxFit.cover),
      );
    } catch (_) {
      return Image.asset(defaultAsset, width: 36, height: 36, fit: BoxFit.cover);
    }
  }
}