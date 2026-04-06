import 'package:flutter/material.dart';

class HorizontalUserCard extends StatelessWidget {
  final String imageUrl;
  final bool isAsset;

  const HorizontalUserCard({
    super.key,
    required this.imageUrl,
    this.isAsset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // Card width
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isAsset
                ? Image.asset(
              imageUrl,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            )
                : Image.network(
              imageUrl,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 5),
        ],
      ),
    );
  }
}