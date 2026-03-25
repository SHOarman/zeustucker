import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custom_text_field.dart';
import 'package:zeustucker/presention/customwidget/custombutton.dart';

import '../../../core/services/controller/login_controller.dart';
import '../../customwidget/buildDropdownCustom.dart';

class Createyouraccound extends StatelessWidget {
  const Createyouraccound({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

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
                controller: controller.Usernamecontroller,
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
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (val) => controller.toggleRememberMe(),
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
              Custombutton(iconname: 'Create account', ontap: () {
                Get.toNamed(AppRoutes.login);
              }),
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
