import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/core/services/controller/login_controller.dart';
import 'package:zeustucker/presention/customwidget/custombutton.dart';

class Onlodaing3 extends GetView<LoginController> {
  const Onlodaing3({super.key});

  static const Color _primary = Color(0xFF00A97D);
  static const Color _textDark = Color(0xFF2D292E);
  static const Color _textGrey = Color(0xFF6B7280);

  @override
  LoginController get controller => Get.put(LoginController());

  // ── Source picker bottom sheet ─────────────────────────────────────────────
  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Upload Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const Divider(height: 20),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: _primary),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              controller.pickImageFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: _primary),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.pop(context);
              controller.pickImageFromCamera();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Logo ───────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/image/newlogu.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 8),

              // ── Daily Storybook badge ──────────────────────────────────
              Center(
                child: Text(
                  'Daily Storybook',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader =
                          const LinearGradient(
                            colors: [Color(0xFF2D292E), Color(0xFF527900)],
                          ).createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────────────
              const Text(
                'Reference Image Upload',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),

              const SizedBox(height: 24),

              // ── Upload card ────────────────────────────────────────────
              Obx(() {
                final path = controller.profileImagePath.value;
                return GestureDetector(
                  onTap: () => _showSourcePicker(context),
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: path != null
                        // ── Preview selected image ─────────────────────
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(path), fit: BoxFit.cover),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () => _showSourcePicker(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        // ── Empty upload placeholder ───────────────────
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 28,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                              const Text(
                                'Camera / Galary',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _textGrey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'For better consistency, use a clear\nfront-facing photo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }),

              const SizedBox(height: 20),


              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  // borderRadius: BorderRadius.circular(12),
                  // border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Use this image for future regenerations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                          ),
                        ),
                      ),
                      Switch(
                        value: controller.useForRegeneration.value,
                        onChanged: (_) => controller.toggleUseForRegeneration(),
                        activeThumbColor: Colors.white,
                        activeTrackColor: _primary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Continue button ────────────────────────────────────────
              Custombutton(
                iconname: 'Continue',
                ontap: () => Get.offAllNamed(AppRoutes.home),
              ),

              const SizedBox(height: 16),


              Center(
                child: Text(
                  'Step 3 of 3',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                    decoration: TextDecoration.underline,
                    decorationColor: _textDark,
                    decorationThickness: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
