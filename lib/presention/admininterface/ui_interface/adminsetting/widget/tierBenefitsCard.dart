import 'package:flutter/material.dart';

class TierBenefitsCard extends StatelessWidget {
  const TierBenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "CURRENT TIER BENEFITS",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9BA6B3),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Benefit Items
          _buildBenefitItem(
            imagePath: "assets/icon/Icon (16).png",
            title: "10 Client Limit",
            subtitle: "Manage up to 10 active storybooks",
          ),
          const SizedBox(height: 20),
          _buildBenefitItem(
            imagePath: "assets/icon/Container (16).png",
            title: "Weekly Bulk Regeneration",
            subtitle: "Update all routines with one tap",
          ),
          const SizedBox(height: 20),
          _buildBenefitItem(
            imagePath: "assets/icon/Container (17).png",
            title: "Advanced AI Art Styles",
            subtitle: "Access to 12 exclusive comic themes",
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Container (Circle shaped)
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F9F5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Image.asset(
            imagePath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7D8B9A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}