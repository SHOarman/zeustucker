import 'package:flutter/material.dart';
import '../../../../../unity/text.dart';

class CustomIconButton extends StatelessWidget {
  final String title;
  final String iconPath; // Changed IconData to String for Image.asset
  final VoidCallback onTap;

  const CustomIconButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF00A37B),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                height: 24,
                width: 24,
                color: Colors.white, // Optional: if you want to tint the asset
              ),
              const SizedBox(width: 12),
              CustomText(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}