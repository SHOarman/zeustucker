import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:zeustucker/core/services/api_services/api_services.dart';

class ClientCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isActive;
  final bool hasRoutine;
  final VoidCallback onEditRoutine;
  final VoidCallback onDelete;

  const ClientCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isActive,
    required this.hasRoutine,
    required this.onEditRoutine,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 335,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Client Image
          SizedBox(
            width: 50,
            height: 50,
            child: ClipOval(
              child: _buildAvatarImage(imageUrl),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                Text(
                  isActive ? "ACTIVE" : "PENDING",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF00B171) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          if (isActive)
            GestureDetector(
              onTap: onEditRoutine,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B171),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasRoutine ? "EDIT ROUTINE" : "CREATE ROUTINE",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Delete Button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF5252),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAvatarImage(String url) {
    const String defaultAsset = 'assets/image/David Park.png';

    if (url.isEmpty || url == 'string' || url == 'null') {
      return Image.asset(defaultAsset, width: 50, height: 50, fit: BoxFit.cover);
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final String altUrl = url.contains(':8000')
              ? url.replaceAll(':8000', ':8004')
              : url.replaceAll(':8004', ':8000');
          return Image.network(
            altUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              defaultAsset,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }

    if (url.startsWith('/')) {
      final String primaryUrl = "${ApiServices.baseUrl}$url";
      final String altUrl = "${ApiServices.baseUrl.replaceAll(':8000', ':8004')}$url";
      return Image.network(
        primaryUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.network(
          altUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            defaultAsset,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          defaultAsset,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }

    try {
      final String cleanBase64 = url.startsWith('data:image') && url.contains('base64,')
          ? url.split('base64,').last
          : url;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          defaultAsset,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Image.asset(defaultAsset, width: 50, height: 50, fit: BoxFit.cover);
    }
  }
}