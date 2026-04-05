import 'package:flutter/material.dart';

class AddUserButton extends StatelessWidget {
  final VoidCallback onTap; // বাটনে ক্লিক করলে কী হবে তা নিয়ন্ত্রণ করার জন্য

  const AddUserButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // পিসিতে ব্যবহার করলে মাউস কার্সার ক্লিকের মতো দেখাবে
        child: Container(
          width: 64, // Figma ডিজাইন অনুযায়ী মাপ
          height: 64,
          padding: const EdgeInsets.all(16), // আইকনের ভেতরের প্যাডিং
          decoration: BoxDecoration(
            color: const Color(0xFF00B171), // Figma-এর সবুজ রঙ
            borderRadius: BorderRadius.circular(20), // হালকা রাউন্ড কর্নার
            boxShadow: [
              // হালকা ড্রপ শ্যাডো
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.person_add_alt_1_outlined, // + চিহ্নসহ ইউজার আইকন
              color: Colors.white, // আইকনের রঙ সাদা
              size: 28, // আইকনের সাইজ
            ),
          ),
        ),
      ),
    );
  }
}