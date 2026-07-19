import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/AccountPreferencesWidget.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/CustomProfileCard.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/CustomSettingTile.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/tierBenefitsCard.dart';

import '../../../../core/services/controller/profilecontroller.dart';
import '../../../../core/routes/app_routes.dart';
import '../adminhome/homewidget/Customadminbutton.dart';

class Accoundperferences extends StatelessWidget {
  const Accoundperferences({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(EditProfileController());

    final userName = ''.obs;
    final emailAddress = ''.obs;
    final phoneNumber = ''.obs;
    final coachBio = ''.obs;

    ever(profileController.profileData, (data) {
      userName.value = data['name'] ?? data['full_name'] ?? '';
      emailAddress.value = data['email'] ?? '';
      phoneNumber.value = data['phone_number'] ?? data['phone'] ?? 'Not Provided';
      coachBio.value = data['bio'] ?? data['short_bio'] ?? '';
    });

    if (profileController.profileData.isNotEmpty) {
      final data = profileController.profileData;
      userName.value = data['name'] ?? data['full_name'] ?? '';
      emailAddress.value = data['email'] ?? '';
      phoneNumber.value = data['phone_number'] ?? data['phone'] ?? 'Not Provided';
      coachBio.value = data['bio'] ?? data['short_bio'] ?? '';
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              const AccountHeaderCard(),
              const SizedBox(height: 30),
              
              const Text(
                "PROFILE DETAILS",
                style: TextStyle(color: Color(0xff9CA3AF), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
              const SizedBox(height: 20),

              CustomProfileCard(
                label: "Full Name",
                value: userName,
              ),

              const SizedBox(height: 15),

              CustomProfileCard(
                label: "EMAIL ADDRESS",
                value: emailAddress,
              ),
              const SizedBox(height: 15),
              CustomProfileCard(
                label: "PHONE NUMBER",
                value: phoneNumber,
              ),

              const SizedBox(height: 30),

              CustomProfileCard(
                label: "COACH BIOGRAPHY",
                value: coachBio,
              ),

              const SizedBox(height: 20),
              const Text(
                "PASSWORD & SECURITY",
                style: TextStyle(color: Color(0xff9CA3AF), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              CustomSettingTile(
                imagePath: 'assets/icon/Container (13).png',
                title: 'Update Password',
                onTap: () {
                  Get.toNamed(AppRoutes.updatepassword);
                },
              ),
              const SizedBox(height: 20),

              CustomIconButton(
                title: "Edit Profile",
                iconPath: "assets/icon/Container (15).png",
                onTap: () {
                  Get.toNamed(AppRoutes.editprofile);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
