import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/controller/profilecontroller.dart';

class CoachPremiumCard extends StatelessWidget {
  const CoachPremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(EditProfileController());

    return FutureBuilder<Map<String, dynamic>?>(
      future: profileController.getSelfProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Color(0xFF1CB08C)),
            ),
          );
        }

        final profile = snapshot.data;
        final String name = profile?['name'] ?? 'Coach Alexander';
        final String email = profile?['email'] ?? 'COACH PREMIUM';
        final String? profileImg = profile?['profile_image'];

        return Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Gear Icon
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

                    // Profile Picture
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1CB08C),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: profileImg != null && profileImg.isNotEmpty && profileImg != 'string'
                              ? (profileImg.startsWith('http')
                                  ? Image.network(
                                      profileImg,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.memory(
                                      base64Decode(profileImg),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ))
                              : Image.asset(
                                  'assets/image/Panel 2.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),

                    // Verification Icon
                    Positioned(
                      bottom: 0,
                      right: 100,
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
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Coach Email
                Text(
                  email,
                  style: const TextStyle(
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
      },
    );
  }
}