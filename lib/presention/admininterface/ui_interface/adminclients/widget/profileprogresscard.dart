import 'package:flutter/material.dart';
import 'dart:convert';

class ClientProfileHeader extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String programName;
  final double progress;
  final bool hasNotification;
  final VoidCallback onBackTap;
  final VoidCallback onMenuTap;

  const ClientProfileHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.programName,
    required this.progress,
    this.hasNotification = false,
    required this.onBackTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    String percentageText = "${(progress * 100).toInt()}%";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(Icons.arrow_back_ios_new, onBackTap),
              _buildIconButton(Icons.more_horiz, onMenuTap),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: ClipOval(
                    child: _buildProgressAvatar(imageUrl),
                  ),
                ),
              ),
              if (hasNotification || progress < 0.50)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D4D),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.priority_high, size: 24, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            programName,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "WEEKLY PROGRESS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                percentageText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B171),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00B171)),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildProgressAvatar(String url) {
    const defaultAsset = 'assets/image/David Park.png';

    if (url.isEmpty || url == 'string' || url == 'null') {
      return Image.asset(defaultAsset, width: 110, height: 110, fit: BoxFit.cover);
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final altUrl = url.contains(':8000') ? url.replaceAll(':8000', ':8004') : url.replaceAll(':8004', ':8000');
          return Image.network(
            altUrl,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, width: 110, height: 110, fit: BoxFit.cover),
          );
        },
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, width: 110, height: 110, fit: BoxFit.cover),
      );
    }

    try {
      final String cleanBase64 = url.startsWith('data:image') && url.contains('base64,')
          ? url.split('base64,').last
          : url;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, width: 110, height: 110, fit: BoxFit.cover),
      );
    } catch (_) {
      return Image.asset(defaultAsset, width: 110, height: 110, fit: BoxFit.cover);
    }
  }
}