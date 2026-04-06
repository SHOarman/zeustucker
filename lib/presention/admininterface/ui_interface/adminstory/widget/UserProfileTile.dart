import 'package:flutter/material.dart';

class CustomUserTile extends StatelessWidget {
  final String userName;
  final String routineText;
  final String imageUrl;
  final bool isAsset;

  const CustomUserTile({
    super.key,
    required this.userName,
    required this.routineText,
    required this.imageUrl,
    this.isAsset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ekhon background color ba shadow nai, tai transparent thakbe
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 1. Check Icon Box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00A36C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // 2. User Profile Image
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage: isAsset
                ? AssetImage(imageUrl) as ImageProvider
                : NetworkImage(imageUrl),
          ),

          const SizedBox(width: 12),

          // 3. User Name
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // 4. Routine Text
          Text(
            routineText.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}