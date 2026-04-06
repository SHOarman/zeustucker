import 'package:flutter/material.dart';
import '../../../../../unity/text.dart';

class Resentaddprofile extends StatelessWidget { // Name changed here
  final String imageUrl;
  final String name;
  final String status;
  final VoidCallback onTap;
  const Resentaddprofile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            // Background Card
            Container(
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

            // Profile Image
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
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: imageUrl.startsWith('http')
                      ? NetworkImage(imageUrl) as ImageProvider
                      : AssetImage(imageUrl),
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ),

            // Name and Status
            Positioned(
              left: 85,
              right: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: status,
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),

            // Right Arrow Icon
            const Positioned(
              right: 20,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF00A37B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}