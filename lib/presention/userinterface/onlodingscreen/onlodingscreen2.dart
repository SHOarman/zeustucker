import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custom_text_field.dart';
import 'package:zeustucker/presention/customwidget/custombutton.dart';

class OnlodingScreen2 extends StatefulWidget {
  const OnlodingScreen2({super.key});

  @override
  State<OnlodingScreen2> createState() => _OnlodingScreen2State();
}

class _OnlodingScreen2State extends State<OnlodingScreen2> {
  static const Color _primary = Color(0xFF00A97D);
  static const Color _textDark = Color(0xFF2D292E);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFDDDDDD);

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedGoal;

  final List<String> _fitnessGoals = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Increase Flexibility',
    'Stay Active',
    'Improve Mental Health',
    'Train for a Sport',
    'General Fitness',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Show fitness goal bottom-sheet picker
  void _showFitnessGoalPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
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
            ..._fitnessGoals.map(
              (goal) => ListTile(
                leading: Icon(
                  Icons.fitness_center,
                  color: _selectedGoal == goal ? _primary : Colors.grey,
                  size: 20,
                ),
                title: Text(
                  goal,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textDark,
                    fontWeight: _selectedGoal == goal
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: _selectedGoal == goal
                    ? const Icon(Icons.check, color: _primary, size: 18)
                    : null,
                onTap: () {
                  setState(() => _selectedGoal = goal);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Tell Us About You',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),

              const SizedBox(height: 24),

              // ── Name ─────────────────────────────────────────────────────
              CustomTextField(
                labelText: 'Name',
                hintText: 'Bonnie Green',
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 16),

              // ── Age ──────────────────────────────────────────────────────
              CustomTextField(
                labelText: 'Age',
                hintText: 'write your age',
                controller: _ageController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // ── Occupation ───────────────────────────────────────────────
              CustomTextField(
                labelText: 'Occupation',
                hintText: 'write occupation',
                controller: _occupationController,
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
                    onTap: _showFitnessGoalPicker,
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
                          Text(
                            _selectedGoal ?? 'Select fitness goal',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedGoal != null
                                  ? _textDark
                                  : const Color(0xFFAAAAAA),
                            ),
                          ),
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

              // ── Short Bio ────────────────────────────────────────────────
              CustomTextField(
                labelText: 'Short Bio',
                hintText: 'write short bio (Optional)',
                controller: _bioController,
              ),

              const SizedBox(height: 32),

              // ── Continue button ──────────────────────────────────────────
              Custombutton(
                iconname: 'Continue',
                ontap: () => Get.toNamed(AppRoutes.onloading3),
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
