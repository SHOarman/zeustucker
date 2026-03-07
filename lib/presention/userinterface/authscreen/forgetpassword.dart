import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _agreeToTerms = false;

  static const Color _primary = Color(0xFF00A97D);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _borderColor = Color(0xFFDDDDDD);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // ── Logo / Illustration ──────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/image/Group.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────────────────────
              const Text(
                'Forget yout Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              // ── Description with tappable link ───────────────────────────
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff6B7280),
                    height: 1.5,
                    letterSpacing: 1,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          "We'll email you instructions to reset your password. "
                          "If you don't have access to your email anymore, you can try ",
                    ),
                    TextSpan(
                      text: 'account recovery',
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: navigate to account recovery
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Email label ──────────────────────────────────────────────
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),

              // ── Email input ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Terms & Privacy checkbox row ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _agreeToTerms,
                      activeColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: _borderColor, width: 1.5),
                      onChanged: (v) =>
                          setState(() => _agreeToTerms = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: _textGrey),
                        children: [
                          const TextSpan(text: "I'am agree to Small Talk "),
                          TextSpan(
                            text: 'Terms of Use',
                            style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: open Terms of Use
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: open Privacy Policy
                              },
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Action buttons row ────────────────────────────────────────
              Row(
                children: [
                  // Forget password button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.verifyEmail);
                        print("arman");
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Forget passwoaed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Return to login text button
                  GestureDetector(
                    onTap: () => Get.offNamed(AppRoutes.login),
                    child: const Text(
                      'Return to login',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
