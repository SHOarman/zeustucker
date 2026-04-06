import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/CoachPremiumCard.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/CustomSettingTile.dart';

import '../../widget/customnevadminbutton.dart';

class Adminsetting extends StatelessWidget {
  const Adminsetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const Customnevadminbutton(selectIndex: 3),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              const CoachPremiumCard(),
              const SizedBox(height: 30),
              const Text(
                "PREFERENCES",
                style: TextStyle(
                  color: Color(0xff9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              CustomSettingTile(
                imagePath: 'assets/icon/Icon (11).png',
                title: 'Account Preferences',
                onTap: () {

                  Get.toNamed(AppRoutes.accoundperferences);
                },
              ),
              CustomSettingTile(
                imagePath: 'assets/icon/Icon (12).png',
                title: 'Client Management Limits',
                onTap: () {
                  Get.toNamed(AppRoutes.clientmanagementlimits);
                },
              ),
              CustomSettingTile(
                imagePath: 'assets/icon/Container (11).png',
                title: 'Subscription & Billing',
                onTap: () {},
              ),
              CustomSettingTile(
                imagePath: 'assets/icon/Container (12).png',
                title: 'Notification Settings',
                onTap: () {},
              ),
              const SizedBox(height: 40),

              // Log Out Button
// Log Out Button
              Material(
                color: const Color(0xFFF3F4F6), // Normal obosthay color
                borderRadius: BorderRadius.circular(40),
                child: InkWell(
                  onTap: () {

                  },
                  borderRadius: BorderRadius.circular(40),
                  splashColor: Colors.black.withOpacity(0.1),
                  highlightColor: Colors.black.withOpacity(0.05),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icon/Icon (13).png',
                          width: 20,
                          height: 20,
                          color: const Color(0xFF374151),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Delete Account Button
              Center(
                child: InkWell(
                  onTap: () {
                    // Delete account logic
                  },
                  borderRadius: BorderRadius.circular(8),
                  splashColor: Colors.red.withOpacity(0.1),
                  highlightColor: Colors.red.withOpacity(0.05),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}