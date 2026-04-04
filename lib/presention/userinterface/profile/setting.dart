import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/customalertDilog.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          "Setting",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CustomSettingCard(
              title: "Edit Profile",
              iconPath: "assets/image/Frame (2).png",
              onTap: () {
                Get.toNamed(AppRoutes.editprofile);
              },
            ),

            const SizedBox(height: 16),

            CustomSettingCard(
              title: "Support & Help",
              iconPath: "assets/image/Frame.png",
              onTap: () {
                Get.toNamed(AppRoutes.support$help);
              },
            ),

            const SizedBox(height: 16),

            CustomSettingCard(
              title: "Delete Account",
              iconPath: "assets/image/Frame (1).png",
              isDelete: true,
              onTap: () {
                Get.dialog(
                  CustomAlertDialog(
                    title: "Delete Account",
                    buttonText: "Delete",
                    onTap: () {},
                    titleColor: Colors.red,
                    iconPath: 'assets/image/Vector (1).png',
                  ),
                );
              },
            ),

            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    CustomAlertDialog(
                      title: "Logout from the app",
                      buttonText: "Logout",
                      onTap: () {},
                      iconPath: 'assets/image/Frame (4).png',
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF5252),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                label: const Icon(Icons.logout, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CustomSettingCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final bool isDelete;

  const CustomSettingCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDelete
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                iconPath,
                width: 20,
                height: 20,
                color: isDelete ? Colors.red : Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDelete ? Colors.red : Colors.black87,
                ),
              ),
            ),

            Icon(
              isDelete ? Icons.delete_outline : Icons.arrow_forward_ios,
              size: 18,
              color: isDelete ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
