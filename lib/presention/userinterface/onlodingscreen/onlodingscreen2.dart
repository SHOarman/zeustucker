import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/core/services/controller/authcontroller.dart';
import 'package:zeustucker/presention/customwidget/custom_text_field.dart';
import 'package:zeustucker/presention/customwidget/custombutton.dart';

class OnlodingScreen2 extends StatelessWidget {
  const OnlodingScreen2({super.key});

  static const Color _primary = Color(0xFF00A97D);
  static const Color _textDark = Color(0xFF2D292E);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFDDDDDD);

  static final List<String> _fitnessGoals = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Increase Flexibility',
    'Stay Active',
    'Improve Mental Health',
    'Train for a Sport',
    'General Fitness',
  ];

  static final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];

  // Show fitness goal bottom-sheet picker
  void _showFitnessGoalPicker(BuildContext context, Authcontroller authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Obx(() {
          final selectedGoal = authController.rxSelectedGoal.value;
          return Column(
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
                'Select Fitness Goal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const Divider(height: 20),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _fitnessGoals.map(
                    (goal) => Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.fitness_center,
                          color: selectedGoal == goal ? _primary : Colors.grey,
                          size: 20,
                        ),
                        title: Text(
                          goal,
                          style: TextStyle(
                            fontSize: 14,
                            color: _textDark,
                            fontWeight: selectedGoal == goal
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: selectedGoal == goal
                            ? const Icon(Icons.check, color: _primary, size: 18)
                            : null,
                        onTap: () {
                          authController.rxSelectedGoal.value = goal;
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        });
      },
    );
  }

  // Show gender bottom-sheet picker
  void _showGenderPicker(BuildContext context, Authcontroller authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Obx(() {
          final selectedGender = authController.rxSelectedGender.value;
          return Column(
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
                'Select Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const Divider(height: 20),
              ..._genders.map(
                (gender) => Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: selectedGender == gender ? _primary : Colors.grey,
                      size: 20,
                    ),
                    title: Text(
                      gender,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textDark,
                        fontWeight: selectedGender == gender
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: selectedGender == gender
                        ? const Icon(Icons.check, color: _primary, size: 18)
                        : null,
                    onTap: () {
                      authController.rxSelectedGender.value = gender;
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(Authcontroller());
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Logo ────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/image/newlogu.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 8),

              // ── Daily Storybook gradient text ────────────────────────────
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

              // ── Section title ────────────────────────────────────────────
              const SizedBox(height: 24),

              // ── Occupation ───────────────────────────────────────────────
              CustomTextField(
                labelText: 'Occupation',
                hintText: 'write occupation',
                controller: authController.occupationController,
              ),

              const SizedBox(height: 16),

              // ── Fitness Goal (tap → bottom sheet popup) ───────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitness Goal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showFitnessGoalPicker(context, authController),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _borderColor, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            final selectedGoal = authController.rxSelectedGoal.value;
                            return Text(
                              selectedGoal ?? 'Select fitness goal',
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedGoal != null
                                    ? _textDark
                                    : const Color(0xFFAAAAAA),
                              ),
                            );
                          }),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: _textGrey,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Gender Selection ──────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showGenderPicker(context, authController),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _borderColor, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            final selectedGender = authController.rxSelectedGender.value;
                            return Text(
                              selectedGender ?? 'Select gender',
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedGender != null
                                    ? _textDark
                                    : const Color(0xFFAAAAAA),
                              ),
                            );
                          }),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: _textGrey,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Height ───────────────────────────────────────────────────
              CustomTextField(
                labelText: 'Height (e.g., 170 cm)',
                hintText: 'Enter height',
                controller: authController.heightController,
              ),

              const SizedBox(height: 16),

              // ── Weight ───────────────────────────────────────────────────
              CustomTextField(
                labelText: 'Weight (kg)',
                hintText: 'Enter weight',
                controller: authController.weightController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // ── Target Weight ────────────────────────────────────────────
              CustomTextField(
                labelText: 'Target Weight (kg)',
                hintText: 'Enter target weight',
                controller: authController.targetWeightController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // ── Short Bio ────────────────────────────────────────────────
              CustomTextField(
                labelText: 'Short Bio',
                hintText: 'write short bio (Optional)',
                controller: authController.bioController,
              ),

              const SizedBox(height: 32),

              // ── Continue button ──────────────────────────────────────────
              Custombutton(
                iconname: 'Continue',
                ontap: () {
                  authController.tempOccupation = authController.occupationController.text.trim();
                  authController.tempFitnessGoal = authController.rxSelectedGoal.value ?? '';
                  authController.tempBio = authController.bioController.text.trim();
                  authController.tempGender = authController.rxSelectedGender.value ?? '';
                  authController.tempHeight = authController.heightController.text.trim();
                  authController.tempWeight = int.tryParse(authController.weightController.text.trim());
                  authController.tempTargetWeight = int.tryParse(authController.targetWeightController.text.trim());
                  Get.toNamed(AppRoutes.onloading3);
                },
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Step 2 of 3',
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
