// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../../../../../unity/text.dart';

class CustomIconButton extends StatelessWidget {
  final String title;
  final String iconPath;
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
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF00A97D),
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: Container(
            height: 56,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  height: 24,
                  width: 24,
                  color: Colors.white,
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
      ),
    );
  }
}