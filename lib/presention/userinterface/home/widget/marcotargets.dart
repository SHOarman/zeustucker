import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MacroTargetCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String iconPath; // Use asset path here: "assets/image/icon.png"
  final Color valueColor;
  final VoidCallback onTap;

  const MacroTargetCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.iconPath,
    required this.valueColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        // width: MediaQuery.of(context).size.width * 0.21,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // PNG Icon Container
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                iconPath,
                height: 30, // Adjusted for PNG sizing
                width: 30,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 2),
            // Value + Unit
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}