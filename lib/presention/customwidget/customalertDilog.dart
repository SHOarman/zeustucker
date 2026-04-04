// ignore_for_file: file_names
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onTap;
  final String iconPath; // Asset image path er jonno
  final Color themeColor;
  final Color titleColor;
  final Color buttonTextColor;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onTap,
    required this.iconPath, // Path pass kora lagbe
    this.themeColor = const Color(0xFFFF5252),
    this.titleColor = const Color(0xFF2D2D2D),
    this.buttonTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- ASSET IMAGE ICON SECTION ---
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: themeColor, width: 1.5),
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   child:
          Image.asset(
                iconPath,
                width: 50,
                height: 50,
                // color: themeColor,
                // errorBuilder: (context, error, stackTrace) => Icon(Icons.warning, color: themeColor),
              ),
            //),
            const SizedBox(height: 24),

            // --- TITLE ---
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 30),

            // --- BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: buttonTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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