import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:zeustucker/core/services/api_services/api_services.dart';
import '../../../../../unity/text.dart';

class UserStoryTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String status;
  final VoidCallback onViewStory;
  final VoidCallback? onTap;

  const UserStoryTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.status,
    required this.onViewStory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 82,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: 60,
                height: 60,
                child: ClipOval(
                  child: _buildAvatarImage(imageUrl),
                ),
              ),
            ),
          ),

          Positioned(
            left: 85,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: name,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1C1E),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: status,
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Positioned(
            right: 15,
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: onViewStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A37B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const CustomText(
                  text: "VIEW STORY",
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
      return Image.asset(defaultAsset, width: 60, height: 60, fit: BoxFit.cover);
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final String altUrl = url.contains(':8000')
              ? url.replaceAll(':8000', ':8004')
              : url.replaceAll(':8004', ':8000');
          return Image.network(
            altUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              defaultAsset,
              width: 60,
              height: 60,
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
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.network(
          altUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            defaultAsset,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          defaultAsset,
          width: 60,
          height: 60,
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
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          defaultAsset,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Image.asset(defaultAsset, width: 60, height: 60, fit: BoxFit.cover);
    }
  }
}