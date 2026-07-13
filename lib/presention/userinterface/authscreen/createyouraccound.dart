import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custom_text_field.dart';
import 'package:zeustucker/presention/customwidget/custombutton.dart';

import '../../../core/services/controller/authcontroller.dart';
import '../../../core/services/controller/login_controller.dart';
import '../../customwidget/build_dropdown_custom.dart';

class Createyouraccound extends StatelessWidget {
  const Createyouraccound({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final Authcontroller authController = Get.put(Authcontroller());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .start,
            children: [
              SizedBox(height: 70),

              Center(
                child: Image.asset(
                  "assets/image/newlogu.png",
                  height: 100,
                  width: 100,
                ),
              ),

              SizedBox(height: 16),
              Center(
                child: Text(
                  'Create your Free Account',
                  style: TextStyle(
                    color: Color(0xff2D292E),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 16),

              CustomTextField(
                labelText: "Email",
                hintText: "name@example.com",
                controller: controller.emailController,
              ),

              SizedBox(height: 16),

              CustomTextField(
                labelText: "Username",
                hintText: "Enter your name",
                controller: controller.usernameController,
              ),

              SizedBox(height: 16),

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

              Obx(
                () => CustomTextField(
                  labelText: 'Confirm Password',
                  hintText: '••••••••••',
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Birth Date",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2D292E),
                ),
              ),
              const SizedBox(height: 8),

              Column(
                children: [
                  buildDropdownCustom(
                    hint: "Day",
                    value: controller.selectedDay,
                    items: controller.days,
                  ),
                  const SizedBox(height: 12),
                  buildDropdownCustom(
                    hint: "Month",
                    value: controller.selectedMonth,
                    items: controller.months,
                  ),
                  const SizedBox(height: 12),
                  buildDropdownCustom(
                    hint: "Year",
                    value: controller.selectedYear,
                    items: controller.years,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                labelText: "Select Role",
                hintText: "Select your role",
                controller: authController.roleController,
                readOnly: true,
                suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFFAAAAAA)),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Material(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Select Role',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff2D292E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Choose your account type to personalize your experience',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Material(
                                color: const Color(0xFFF9FAFB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A97D).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF00A97D),
                                      size: 24,
                                    ),
                                  ),
                                  title: const Text(
                                    'SELF',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xff2D292E),
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Track your workouts and read stories',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  onTap: () {
                                    authController.selectedRole.value = 'SELF';
                                    authController.roleController.text = 'SELF';
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Material(
                                color: const Color(0xFFF9FAFB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A97D).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sports_outlined,
                                      color: Color(0xFF00A97D),
                                      size: 24,
                                    ),
                                  ),
                                  title: const Text(
                                    'COACH',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xff2D292E),
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Manage clients and direct their fitness journeys',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  onTap: () {
                                    authController.selectedRole.value = 'COACH';
                                    authController.roleController.text = 'COACH';
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.agreeToTerms.value,
                      onChanged: (val) => controller.toggleTerms(),
                      activeColor: const Color(0xFF00A97D),
                    ),
                  ),
                  const Text(
                    "I accept the ",
                    style: TextStyle(color: Color(0xff111928)),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Terms and Conditions",
                      style: TextStyle(
                        color: Color(0xFF00A97D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => Custombutton(
                    iconname: 'Create account', 
                    isLoading: authController.isLoading.value,
                    ontap: () {
                      if (!controller.agreeToTerms.value) {
                         Get.snackbar('Error', 'Please accept the Terms and Conditions', backgroundColor: Colors.red, colorText: Colors.white);
                         return;
                      }

                      if (controller.passwordController.text != controller.confirmPasswordController.text) {
                         Get.snackbar('Error', 'Passwords do not match', backgroundColor: Colors.red, colorText: Colors.white);
                         return;
                      }
                      
                      String dob;
                      if (controller.selectedYear.value.isEmpty ||
                          controller.selectedMonth.value.isEmpty ||
                          controller.selectedDay.value.isEmpty) {
                        dob = "1990-01-01";
                      } else {
                        int monthIndex =
                            controller.months.indexOf(
                              controller.selectedMonth.value,
                            ) +
                            1;
                        String monthStr = monthIndex.toString().padLeft(2, '0');
                        dob =
                            "${controller.selectedYear.value}-$monthStr-${controller.selectedDay.value.padLeft(2, '0')}";
                      }

                      authController.register(
                        username: controller.usernameController.text.trim(),
                        email: controller.emailController.text.trim(),
                        password: controller.passwordController.text,
                        confirmPassword: controller.confirmPasswordController.text,
                        dateOfBirth: dob,
                        role: authController.selectedRole.value,
                      );
                    },
                  ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                   Get.toNamed(AppRoutes.login);
                  },
                  child: Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Color(0xff06D7A0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
