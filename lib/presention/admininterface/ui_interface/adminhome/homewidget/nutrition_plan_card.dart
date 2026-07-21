import 'package:flutter/material.dart';

class NutritionPlanCard extends StatelessWidget {
  // Controller gula baire theke pass korbe jate data collect kora jay
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatsController;
  final TextEditingController fiberController;

  const NutritionPlanCard({
    super.key,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatsController,
    required this.fiberController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Row 1: Calories & Protein
          Row(
            children: [
              Expanded(child: _buildInput('CALORIES (KCAL)', caloriesController)),
              const SizedBox(width: 20),
              Expanded(child: _buildInput('PROTEIN (G)', proteinController)),
            ],
          ),
          const SizedBox(height: 24),
          // Row 2: Carbs & Fats
          Row(
            children: [
              Expanded(child: _buildInput('CARBS (G)', carbsController)),
              const SizedBox(width: 20),
              Expanded(child: _buildInput('FATS (G)', fatsController)),
            ],
          ),
          const SizedBox(height: 24),
          // Row 3: Fiber
          Row(
            children: [
              Expanded(child: _buildInput('FIBER (G)', fiberController)),
              const SizedBox(width: 20),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for input fields
  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F7),
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
        ),
      ],
    );
  }
}