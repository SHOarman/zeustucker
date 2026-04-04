import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isActive;
  final VoidCallback onEditRoutine;
  final VoidCallback onDelete;

  const ClientCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isActive,
    required this.onEditRoutine,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 335,
      // height: ,
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
          CircleAvatar(
            radius: 25,
            backgroundImage: imageUrl.startsWith('http') ? NetworkImage(imageUrl) as ImageProvider : AssetImage(imageUrl),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

          // Edit Routine Button
          GestureDetector(
            onTap: onEditRoutine,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B171), // Green Button
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "EDIT ROUTINE",
                style: TextStyle(
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
}