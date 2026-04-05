import 'package:flutter/material.dart';

class RoutineNeedsReviewCard extends StatelessWidget {
  final String name;
  final String routineName;
  final String imageUrl;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onButtonTap;
  final VoidCallback? onCardTap;

  const RoutineNeedsReviewCard({
    super.key,
    required this.name,
    required this.routineName,
    required this.imageUrl,
    required this.buttonText,
    this.buttonColor = const Color(0xFF15803D),
    this.onButtonTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            CircleAvatar(

              radius: 28,
              backgroundColor: const Color(0xFFF3F4F6),
              backgroundImage: imageUrl.startsWith('assets')
                  ? AssetImage(imageUrl) as ImageProvider
                  : imageUrl.startsWith('http') ? NetworkImage(imageUrl) as ImageProvider : AssetImage(imageUrl) as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    routineName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onButtonTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: buttonColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}