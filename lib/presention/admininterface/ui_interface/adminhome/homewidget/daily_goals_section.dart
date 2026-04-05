import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';

class DailyGoalsSection extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());
  final VoidCallback onSave;

  DailyGoalsSection({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildGoalItem("Drink 3L Water", controller.drinkWater),
              _buildDivider(),
              _buildGoalItem("10k Steps", controller.steps10k),
              _buildDivider(),
              _buildGoalItem("No Sugar Today", controller.noSugar),
              _buildDivider(),
              _buildGoalItem("8 Hours Sleep", controller.sleep8Hours),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Save Button
        _buildSaveButton(),
      ],
    );
  }

  // Individual Goal Row with InkWell for better Tap feel
  Widget _buildGoalItem(String title, RxBool goalState) {
    return InkWell(
      onTap: () => controller.toggleGoal(goalState),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            // Reactive Checkbox using Obx
            Obx(() => Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: goalState.value ? const Color(0xFF00B171) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: goalState.value ? const Color(0xFF00B171) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: goalState.value
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            )),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.shade100, indent: 60);

  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent, // Shadow thik rakhar jonno transparent
      child: InkWell(
        onTap: onSave,
        borderRadius: BorderRadius.circular(32), // Border radius splash-er jonno
        splashColor: Colors.white.withValues(alpha: 0.2), // Click korle halka shada ripple hobe
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF00B171), // Figma Green
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B171).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Save & Generate Story',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NOTIFIES SARAH JENKINS',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}