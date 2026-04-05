import 'package:flutter/material.dart';

class WorkoutPlanSection extends StatelessWidget {
  final VoidCallback onAddPressed;
  final TextEditingController exerciseController; // Controller-ta baire theke ana bhalo

  const WorkoutPlanSection({
    super.key,
    required this.onAddPressed,
    required this.exerciseController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Width shoriye deya hoyeche jate parent padding manage kore
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Bhetorer padding tuku thakbe jate content gula border-e lege na jay
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Existing Exercise Item
          _buildExerciseItem("45min HIIT Session"),

          const SizedBox(height: 16),

          // Add Exercise Input Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: exerciseController,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Add exercise (e.g. 5k Run)',
                      hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Plus Button
              GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFB4F556), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          const Icon(Icons.close, color: Colors.black26, size: 20),
        ],
      ),
    );
  }
}