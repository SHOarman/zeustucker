import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDottedCard extends StatelessWidget {
  final String bodyText;
  final Widget centerWidget; // Changed from IconData to Widget
  final VoidCallback onTap;

  const CustomDottedCard({
    super.key,
    required this.bodyText,
    required this.centerWidget, // Pass your Image.asset or Icon here
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DottedBorderPainter(
          color: Colors.grey[400]!,
          strokeWidth: 1.5,
          gap: 5,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2).withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // This will now display whatever widget you pass
              centerWidget,
              const SizedBox(height: 10),
              Text(
                bodyText,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Dotted Border Painter ---
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DottedBorderPainter({required this.color, this.strokeWidth = 1.5, this.gap = 5});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(15),
      ));

    double dashWidth = 5;
    double dashSpace = gap;
    double distance = 0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}