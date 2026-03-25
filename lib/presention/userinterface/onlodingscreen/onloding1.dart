import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custombutton.dart';

class Onloding1 extends StatelessWidget {
  const Onloding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .start,
            children: [
              SizedBox(height: 60),

              Center(
                child: Image.asset(
                  "assets/image/newlogu.png",
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  "Daily Storybook",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader =
                          const LinearGradient(
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

              SizedBox(height: 64),
              Center(
                child: Text(
                  'Turn Your Routine\n Into A Daily Story',
                  style: TextStyle(
                    color: Color(0xff2D292E),
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Gamify your fitness journey.',
                  style: TextStyle(
                    color: Color(0xff2D292E),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Center(
                child: Text(
                  'Live your own epic saga.',
                  style: TextStyle(
                    color: Color(0xff2D292E),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 300),
              Custombutton(iconname: "Get Started", ontap: () {
                Get.toNamed(AppRoutes.onloading2);
              }),
              SizedBox(height: 10),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      'Step 1 of 3',
                      style: TextStyle(
                        color: Color(0xff2D292E),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xff2D292E),
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
