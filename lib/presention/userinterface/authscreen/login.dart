import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import '../../../core/services/controller/login_controller.dart';
import '../../customwidget/custom_text_field.dart';
import '../../customwidget/custombutton.dart';
import '../../customwidget/customsocialbutton.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 48),

              _buildLogo(),

               SizedBox(height: 16),
               Text(
                'Log in or signup',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2D292E),
                ),
              ),

               SizedBox(height: 32),

              // ── Email Field ──
              CustomTextField(
                labelText: 'Email',
                hintText: 'name@example.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              Obx(
                () => CustomTextField(
                  labelText: 'Password',
                  hintText: '••••••••••',
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                        () => GestureDetector(
                      onTap: controller.toggleRememberMe,
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: (val) => controller.toggleRememberMe(),
                              activeColor: const Color(0xFF00A97D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.forgetPassword);
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF00A97D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Custombutton(
                iconname: 'Continue',
                ontap: () {
                  Get.toNamed(AppRoutes.selectuser);
                },
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account yet? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF777777),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.createyouraccound);
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF00A97D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),




              const SizedBox(height: 24),

              // const SizedBox(height: 28),
              _buildDivider(),

              const SizedBox(height: 20),

              CustomSocialButton(
                label: 'Sign up with Google',
                icon: SvgPicture.asset('assets/icon/Google.svg', width: 20),
                onTap: () => () {},
              ),

              const SizedBox(height: 14),

              CustomSocialButton(
                label: 'Sign up with Apple',
                icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                onTap: () => () {},
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 80,

      child: Image.asset(
        "assets/icon/iconlogu.png",
        errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 50),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color:Color(0xff6B7280))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('or', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(child: Divider(color:Color(0xff6B7280))),
      ],
    );
  }
}
