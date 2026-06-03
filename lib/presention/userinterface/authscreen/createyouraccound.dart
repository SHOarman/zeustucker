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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Select Role', style: TextStyle(fontWeight: FontWeight.bold)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      authController.selectedRole.value = 'user';
                                      authController.roleController.text = 'user';
                                      Get.back();
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Center(
                                          child: Text('User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      authController.selectedRole.value = 'coach';
                                      authController.roleController.text = 'coach';
                                      Get.back();
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Center(
                                          child: Text('Coach', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
              Obx(() => authController.isLoading.value 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A97D)))
                : Custombutton(
                    iconname: 'Create account', 
                    ontap: () {
                      if (!controller.agreeToTerms.value) {
                         Get.snackbar('Error', 'Please accept the Terms and Conditions', backgroundColor: Colors.red, colorText: Colors.white);
                         return;
                      }
                      
                      String dob = "\${controller.selectedYear.value}-\${controller.selectedMonth.value.padLeft(2, '0')}-\${controller.selectedDay.value.padLeft(2, '0')}";
                      if (controller.selectedYear.value.isEmpty) {
                        dob = "1990-01-01"; // Fallback
                      }

                      authController.register(
                        username: controller.usernameController.text.trim(),
                        email: controller.emailController.text.trim(),
                        password: controller.passwordController.text,
                        confirmPassword: controller.passwordController.text, // Assuming no confirm pass field in UI
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
