import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final bool useJakarta; // Jakarta font use korben ki na seta decide korben

  const CustomText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.useJakarta = true,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle style = useJakarta
        ? GoogleFonts.plusJakartaSans(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? const Color(0xFF1A1A1A),
    )
        : TextStyle(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? const Color(0xFF1A1A1A),
    );

    return Text(
      text,
      textAlign: textAlign,
      style: style,
    );
  }
}