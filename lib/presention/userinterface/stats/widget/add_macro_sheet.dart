import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/macro_controller.dart';

class AddMacroSheet extends StatefulWidget {
  final String title;
  final List<LoggedMeal> recentFoods;
  final void Function(double grams, {String? foodName, String? logId}) onAdd;

  const AddMacroSheet({
    super.key,
    required this.title,
    required this.recentFoods,
    required this.onAdd,
  });

  @override
  State<AddMacroSheet> createState() => _AddMacroSheetState();
}

class _AddMacroSheetState extends State<AddMacroSheet> {
  String _input = '0';
  int _selectedFoodIndex = -1;

  void _onNumTap(String digit) {
    setState(() {
      if (_input == '0') {
        _input = digit;
      } else {
        if (_input.length < 5) _input += digit;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_input.length <= 1) {
        _input = '0';
      } else {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _onDot() {
    setState(() {
      if (!_input.contains('.')) _input += '.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF323232),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF323232),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.recentFoods.isNotEmpty) ...[
                      // Recent Foods
                      const Text(
                        'Recent Foods',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF323232),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Food list
                      ...List.generate(widget.recentFoods.length, (i) {
                        final food = widget.recentFoods[i];
                        final isSelected = _selectedFoodIndex == i;

                        // Compute default category color
                        Color categoryColor = const Color(0xFF00A781);
                        final titleLower = widget.title.toLowerCase();
                        if (titleLower.contains('carb')) {
                          categoryColor = const Color(0xFFFFB300);
                        } else if (titleLower.contains('fat')) {
                          categoryColor = const Color(0xFFF44336);
                        } else if (titleLower.contains('fiber') || titleLower.contains('misc')) {
                          categoryColor = const Color(0xFF9C27B0);
                        }

                        // Compute subtitle from LoggedMeal details
                        final amountPart = food.amount != null
                            ? '${food.amount!.toStringAsFixed(0)} ${food.amountUnit ?? "serving"}'
                            : '';
                        final kcalPart = '${food.kcal} kcal';
                        final subtitle = amountPart.isNotEmpty ? '$amountPart • $kcalPart' : kcalPart;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFoodIndex = i;
                              // Auto-fill amount if it exists
                              if (food.amount != null && food.amount! > 0) {
                                _input = food.amount!.toStringAsFixed(0);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00A781).withValues(alpha: 0.08)
                                  : const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00A781)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    color: categoryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF323232),
                                        ),
                                      ),
                                      Text(
                                        subtitle,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF00A781),
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],

                    // Amount display
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _input,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00A781),
                              ),
                            ),
                            const TextSpan(
                              text: ' g',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'AMOUNT IN GRAMS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Numpad
                    _Numpad(
                      onDigit: _onNumTap,
                      onBackspace: _onBackspace,
                      onDot: _onDot,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Add to Daily Log button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final grams = double.tryParse(_input) ?? 0;
                    if (grams > 0) {
                      final selectedFood = _selectedFoodIndex != -1
                          ? widget.recentFoods[_selectedFoodIndex]
                          : null;
                      widget.onAdd(
                        grams,
                        foodName: selectedFood?.name,
                        logId: selectedFood?.id,
                      );
                      Get.back();
                      Get.snackbar(
                        'Added!',
                        '${grams.toStringAsFixed(0)}g added to ${widget.title}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF00A781),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add to Daily Log',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A781),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Numpad widget
// ─────────────────────────────────────────────────────────────────────────────
class _Numpad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onDot;

  const _Numpad({
    required this.onDigit,
    required this.onBackspace,
    required this.onDot,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: keys
          .expand((row) => row)
          .map(
            (k) => GestureDetector(
              onTap: () {
                if (k == '⌫') {
                  onBackspace();
                } else if (k == '.') {
                  onDot();
                } else {
                  onDigit(k);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  k,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF323232),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
