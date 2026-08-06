import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../../unity/text.dart';


class StoryCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Builder(
                builder: (context) {
                  final String rawUrl = imageUrl;
                  if (rawUrl.startsWith('data:image')) {
                    final String cleanBase64 = rawUrl.contains('base64,') ? rawUrl.split('base64,').last : rawUrl;
                    try {
                      final bytes = base64Decode(cleanBase64);
                      return Image.memory(
                        bytes,
                        height: 190,
                        width: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 190,
                          width: 140,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      );
                    } catch (_) {
                      return Container(
                        height: 190,
                        width: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey),
                      );
                    }
                  } else if (rawUrl.startsWith('http')) {
                    return Image.network(
                      rawUrl,
                      height: 190,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 190,
                        width: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    );
                  } else {
                    return Image.asset(
                      rawUrl,
                      height: 190,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 190,
                        width: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            CustomText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1C1E),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            CustomText(
              text: author,
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}