import 'package:flutter/material.dart';

class CustomSocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Widget icon;
  final Color borderColor;

  const CustomSocialButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    this.borderColor = const Color(0xFFDDDDDD),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}