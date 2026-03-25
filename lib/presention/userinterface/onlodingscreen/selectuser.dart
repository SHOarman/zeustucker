import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';

class Selectuser extends StatelessWidget {
  const Selectuser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            Center(
              child: Image.asset(
                "assets/image/newlogu.png",
                height: 100,
                width: 100,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                "Daily Storybook",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: <Color>[
                        Color(0xFF2D292E),
                        Color(0xFF527900),
                      ],
                    ).createShader(
                      const Rect.fromLTWH(0.0, 0.0, 200.50, 70.0),
                    ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            _buildSelectionCard(
              context,
              title: "User",
              imagePath: "assets/image/user.png",
              onTap: () {
               Get.toNamed(AppRoutes.onloading1);

              },
            ),

            const SizedBox(height: 60),

            _buildSelectionCard(
              context,
              title: "Coach",
              imagePath: "assets/image/coach.png",
              onTap: () {
                debugPrint("Coach Selected");

              },
            ),
            const SizedBox(height: 100),
            // Custombutton(iconname: "", ontap: (){})
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context,
      {required String title, required String imagePath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 140,
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00C9B7),
                  Color(0xFF00A395),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),


        ],
      ),
    );
  }
}