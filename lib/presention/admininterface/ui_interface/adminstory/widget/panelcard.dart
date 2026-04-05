import 'package:flutter/material.dart';

class Panelcard extends StatelessWidget {
  final String imageUrl;
  final String? panelName; // উপরের নামের জন্য (ঐচ্ছিক)
  final bool showTick;     // নিচের টিকমার্ক দেখানোর জন্য
  final double width;
  final double height;

  const Panelcard({
    super.key,
    required this.imageUrl,
    this.panelName,
    this.showTick = false,
    this.width = 160,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ১. প্রধান ইমেজ কন্টেইনার (Rounded Corners সহ)
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: DecorationImage(
              image: imageUrl.startsWith('http') ? NetworkImage(imageUrl) as ImageProvider : AssetImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ২. উপরের প্যানেল নাম (যদি panelName দেওয়া থাকে)
        if (panelName != null)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                panelName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

        // ৩. নিচের টিকমার্ক (যদি showTick true থাকে)
        if (showTick)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50), // সবুজ রঙ
                size: 28,
              ),
            ),
          ),
      ],
    );
  }
}