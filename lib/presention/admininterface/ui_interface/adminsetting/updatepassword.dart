import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/update_password_controller.dart';

class UpdatePassword extends StatelessWidget {
  const UpdatePassword({super.key});

  static const Color _textDark = Color(0xFF2D292E);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFDDDDDD);

  Widget _buildPasswordField({
    required String label,
    required TextEditingController textController,
    required RxBool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Obx(
            () => TextField(
              controller: textController,
              obscureText: !isVisible.value,
              style: const TextStyle(fontSize: 14, color: _textDark),
              decoration: InputDecoration(
                hintText: '••••••••••',
                hintStyle: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isVisible.value ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: onToggle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdatePasswordController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Custom Header with back button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "UPDATE PASSWORD",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter your current password and your new password to update security details.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textGrey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // Current Password Field
                _buildPasswordField(
                  label: 'Current Password',
                  textController: controller.currentPasswordController,
                  isVisible: controller.isCurrentPasswordVisible,
                  onToggle: controller.toggleCurrentPasswordVisibility,
                ),

                const SizedBox(height: 20),

                // New Password Field
                _buildPasswordField(
                  label: 'New Password',
                  textController: controller.newPasswordController,
                  isVisible: controller.isNewPasswordVisible,
                  onToggle: controller.toggleNewPasswordVisibility,
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                _buildPasswordField(
                  label: 'Confirm Password',
                  textController: controller.confirmPasswordController,
                  isVisible: controller.isConfirmPasswordVisible,
                  onToggle: controller.toggleConfirmPasswordVisibility,
                ),

                const SizedBox(height: 40),

                // Update Password Button
                Obx(
                  () => Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A97D),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: InkWell(
                        onTap: controller.isLoading.value
                            ? null
                            : () => controller.updatePassword(),
                        borderRadius: BorderRadius.circular(30),
                        splashColor: Colors.white.withValues(alpha: 0.1),
                        highlightColor: Colors.transparent,
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Update Password",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
