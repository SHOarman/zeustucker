import 'package:flutter/material.dart';

class DailyGoalsSection extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onAddPressed;
  final TextEditingController goalInputController;
  final List<String> goals;
  final Function(int) onRemovePressed;

  const DailyGoalsSection({
    super.key,
    required this.onSave,
    required this.onAddPressed,
    required this.goalInputController,
    required this.goals,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dynamic Daily Goal Items
              ...goals.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildGoalItem(item, () => onRemovePressed(idx)),
                );
              }),

              if (goals.isNotEmpty) const SizedBox(height: 8),

              // Add Goal Input Row
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
                        controller: goalInputController,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Add daily goal (e.g. Drink 3L Water)',
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
        ),

        const SizedBox(height: 32),

        // Save Button
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildGoalItem(String title, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF00B171), size: 22),
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
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSave,
        borderRadius: BorderRadius.circular(32),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF00B171),
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
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: const Text(
              'Save Routine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}