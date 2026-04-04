// ignore_for_file: file_names
import 'package:flutter/material.dart';

class ClientInvitationCard extends StatelessWidget {
  final String email;
  final String timeText;
  final String status;

  const ClientInvitationCard({
    super.key,
    required this.email,
    required this.timeText,
    required this.status,
  });

  // Function to get color based on status
  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return const Color(0xFF65C418); // Figma Green
      case 'EXPIRED':
        return const Color(0xFF7D7F8E); // Figma Grey
      case 'SENT':
      default:
        return const Color(0xFF1976D2); // Figma Blue
    }
  }

  // Function to get background color based on status
  Color _getStatusBgColor() {
    return _getStatusColor().withValues(alpha: 0.08);
  }

  @override
  Widget build(BuildContext context) {
    // 322px specific width use kora hoyeche Figma layout wise
    return Container(
      width: 322,
      // margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Email and Time Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Hug content (Height auto)
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A), // Figma Text Color
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7D7F8E), // Figma Subtext Color
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8), // Gap

          // Status Chip (SENT, ACCEPTED, EXPIRED)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBgColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Inner dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),

                // Status Text
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800, // Figma text weight
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}