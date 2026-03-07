import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';

class VerifyYourEmailAddress extends StatefulWidget {
  const VerifyYourEmailAddress({super.key});

  @override
  State<VerifyYourEmailAddress> createState() => _VerifyYourEmailAddressState();
}

class _VerifyYourEmailAddressState extends State<VerifyYourEmailAddress> {
  static const int _otpLength = 6;
  static const Color _primary = Color(0xFF00A97D);
  static const Color _textDark = Color(0xFF2D292E);
  static const Color _textGrey = Color(0xFF2D292E);

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
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
        'assets/image/Group.png',
        errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 50),
      ),
    );
  }

  // ── Single OTP box ────────────────────────────────────────────────────────
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
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
        onChanged: (value) => _onOtpDigitChanged(value, index),
      ),
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

              // ── Description ───────────────────────────────────────────────
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: _textGrey,
                    height: 1.55,
                    letterSpacing: 0.2,
                  ),
                  children: [
                    TextSpan(text: 'We emailed you a six-digit code to\n'),
                    TextSpan(
                      text: 'name@company.com',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    TextSpan(
                      text:
                          '. Enter the code below to confirm your email adress.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── OTP boxes ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) => _buildOtpBox(i)),
              ),

              const SizedBox(height: 20),

              // ── Info note ────────────────────────────────────────────────
              Text(
                'Make sure to keep this window open while check your inbox',
                style: TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
              ),

              const SizedBox(height: 28),

              // ── Verify button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final otp = _controllers.map((c) => c.text).join();
                    print('OTP entered: $otp');
                    Get.toNamed(AppRoutes.createNewPassword);
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
                    'Verify',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
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
