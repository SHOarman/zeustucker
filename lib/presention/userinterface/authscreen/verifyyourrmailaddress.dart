import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/controller/authcontroller.dart';
import '../../customwidget/custombutton.dart';

class VerifyYourEmailAddress extends StatelessWidget {
  const VerifyYourEmailAddress({super.key});

  static const int _otpLength = 6;
  static const Color _primary = Color(0xFF00A97D);
  static const Color _textDark = Color(0xFF2D292E);
  static const Color _textGrey = Color(0xFF2D292E);

  void _onOtpDigitChanged(String value, int index, Authcontroller authController) {
    if (value.length == 1 && index < _otpLength - 1) {
      authController.otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      authController.otpFocusNodes[index - 1].requestFocus();
    }
  }

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

  // ── Single OTP box ────────────────────────────────────────────────────────
  Widget _buildOtpBox(int index, Authcontroller authController) {
    return SizedBox(
      width: 46,
      height: 52,
      child: TextField(
        controller: authController.otpControllers[index],
        focusNode: authController.otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _textDark,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => _onOtpDigitChanged(value, index, authController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(Authcontroller());
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // ── Logo ──────────────────────────────────────────────────────
              Center(child: _buildLogo()),

              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────────────────
              const Text(
                'Verify your email adress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 12),

              Obx(() {
                final email = authController.registeredEmail.value.isEmpty
                    ? 'your email'
                    : authController.registeredEmail.value;
                return RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textGrey,
                      height: 1.55,
                      letterSpacing: 0.2,
                    ),
                    children: [
                      const TextSpan(text: 'We emailed you a six-digit code to\n'),
                      TextSpan(
                        text: email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const TextSpan(
                        text: '. Enter the code below to confirm your email address.',
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 28),

              // ── OTP boxes ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) => _buildOtpBox(i, authController)),
              ),

              const SizedBox(height: 20),

              // ── Info note ────────────────────────────────────────────────
              const Text(
                'Make sure to keep this window open while check your inbox',
                style: TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
              ),

              const SizedBox(height: 28),

              // ── Verify button ─────────────────────────────────────────────
              Center(
                child: Obx(() {
                  return Custombutton(
                    iconname: 'Verify',
                    isLoading: authController.isLoading.value,
                    ontap: () {
                      final otp = authController.otpControllers.map((c) => c.text).join();
                      debugPrint('OTP entered: $otp');
                      authController.verifyEmail(
                        email: authController.registeredEmail.value,
                        code: otp,
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
