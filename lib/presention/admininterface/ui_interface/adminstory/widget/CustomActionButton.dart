import 'package:flutter/material.dart';

class CustomActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  State<CustomActionButton> createState() => _CustomActionButtonState();
}

class _CustomActionButtonState extends State<CustomActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF00A37B);
    final Color bgColor = widget.isPrimary ? primaryGreen : Colors.white;
    final Color contentColor = widget.isPrimary ? Colors.white : const Color(0xFF2D3436);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 60,
          clipBehavior: Clip.antiAlias, // Reflection-ta corner-e kete jabar jonno
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: widget.isPrimary
                    ? primaryGreen.withOpacity(_isPressed ? 0.2 : 0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isPressed ? 10 : 15,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
            border: widget.isPrimary ? null : Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              // --- Reflection/Shine Layer ---
              if (widget.isPrimary)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.15), // Shimmer/Reflection light
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.3, 0.5, 0.7],
                      ),
                    ),
                  ),
                ),

              // --- Button Content (Text & Icon) ---
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: contentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: contentColor, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}