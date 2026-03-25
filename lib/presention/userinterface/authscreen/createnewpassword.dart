import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/core/services/controller/login_controller.dart';

class CreateNewPassword extends GetView<LoginController> {
  const CreateNewPassword({super.key});

  static const Color _primary = Color(0xFF00A97D);
  static const Color _textDark = Color(0xFF2D292E);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFDDDDDD);
  static const Color _textexta= Color(0xff1C64F2);

  @override
  LoginController get controller => Get.put(LoginController());

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/image/newlogu.png',
        errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 50),
      ),
    );
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              Center(child: _buildLogo()),

              const SizedBox(height: 24),

              const Text(
                'Create new password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your new password must be different from\n previous used passwords.',
                style: TextStyle(fontSize: 14, color: _textGrey, height: 1.5),
              ),

              const SizedBox(height: 28),

              // New Password
              _buildPasswordField(
                label: 'New Password',
                textController: controller.newPasswordController,
                isVisible: controller.isPasswordVisible,
                onToggle: controller.togglePasswordVisibility,
              ),

              const SizedBox(height: 18),

              // Confirm Password
              _buildPasswordField(
                label: 'Confirm Password',
                textController: controller.confirmPasswordController,
                isVisible: controller.isConfirmPasswordVisible,
                onToggle: controller.toggleConfirmPasswordVisibility,
              ),

              const SizedBox(height: 16),

              // Terms & Privacy
              Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: controller.agreeToTerms.value,
                        activeColor: _primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: _borderColor, width: 1.5),
                        onChanged: (_) => controller.toggleTerms(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textGrey,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to Small Talk '),
                            TextSpan(
                              text: 'Terms of Use',
                              style: const TextStyle(
                                color: _textexta,
                                fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                letterSpacing: 0.5

                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: _textexta,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                  letterSpacing: 0.5
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    controller.submitNewPassword();
                   Get.toNamed(AppRoutes.verified);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Forget Passwoaed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Support link
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: _textGrey),
                    children: [
                      const TextSpan(text: 'If you still need help, contact '),
                      TextSpan(
                        text: 'Small Talk Support.',
                        style: const TextStyle(
                          color: _textexta,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
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
