import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../core/services/controller/profilecontroller.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE IMAGE SECTION
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Obx(() => CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: controller.selectedImagePath.value.isEmpty
                            ? const AssetImage('assets/image/newprofile.png') as ImageProvider
                            : FileImage(File(controller.selectedImagePath.value)),
                      )),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
                            ),
                            child: const Icon(Icons.camera_alt, size: 20, color: Color(0xFF00A97D)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.nameController,
                    builder: (context, value, child) => Text(
                      value.text.isEmpty ? 'Your Name' : value.text,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.professionController,
                    builder: (context, value, child) => Text(
                      value.text.isEmpty ? 'Profession' : value.text,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // INPUT FIELD CARDS
            _buildInputField(label: 'Full Name', controller: controller.nameController),
            _buildInputField(label: 'Email Address', controller: controller.emailController),
            _buildInputField(label: 'Profession', controller: controller.professionController),

            // DATE OF BIRTH CARD
            _buildLabel('Date of Birth (Age)'),
            GestureDetector(
              onTap: () => controller.chooseDate(context),
              child: _buildCardContainer(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 12),
                    Obx(() => Text(
                      controller.dob.value,
                      style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                    )),
                    const Spacer(),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        '${controller.age.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // GENDER CARD
            _buildLabel('Gender'),
            GestureDetector(
              onTap: () => controller.showGenderSelection(context),
              child: _buildCardContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      controller.selectedGender.value,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    )),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Get.snackbar("Success", "Profile Updated Successfully!",
                    backgroundColor: Colors.white, colorText: Colors.black),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A97D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD INDIVIDUAL INPUT CARD
  Widget _buildInputField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildCardContainer(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // BUILD LABEL
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4A4A4A))),
    );
  }

  // BUILD CARD CONTAINER
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}