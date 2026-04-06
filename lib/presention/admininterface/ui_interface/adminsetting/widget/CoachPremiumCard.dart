import 'package:flutter/material.dart';

class CoachPremiumCard extends StatelessWidget {
  const CoachPremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold bad deya hoyeche, sudhu Container/Card use kora hoyeche
    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Card size content onujayi hobe
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Gear Icon (Nicher konay)
                Positioned(
                  bottom: -122,
                  left: -25,
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/icon/Icon (8).png',
                      width: 80,
                    ),
                  ),
                ),

                // Profile Picture (Center)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1CB08C),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/Panel 2.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Verification Icon (Right Side)
                Positioned(
                  bottom: 0,
                  right: 100, // Tomar design onujayi adjust koro
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1CB08C),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/icon/Icon (10).png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Coach Name
            const Text(
              'Coach Alexander',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 10),
            // Coach Premium Text
            const Text(
              'COACH PREMIUM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1CB08C),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}