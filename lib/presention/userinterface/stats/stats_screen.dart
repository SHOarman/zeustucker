import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/macro_controller.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily put controller if not already registered
    final MacroController ctrl = Get.put(MacroController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: const CustomBottomNav(selectIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MacroHeader(ctrl: ctrl),
            const SizedBox(height: 24),
            _MacroRow(ctrl: ctrl),
            const SizedBox(height: 20),
            LoggedMealsSection(ctrl: ctrl),
            const SizedBox(height: 20),
            _DailyNotesSection(ctrl: ctrl),
            const SizedBox(height: 24),
            _SaveRoutineButton(),
            const SizedBox(height: 12),
            const Text(
              'Story scences will be generated based on this.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header – "Today's Macro" + calorie ring + multiplier
// ─────────────────────────────────────────────────────────────────────────────
class _MacroHeader extends StatelessWidget {
  final MacroController ctrl;
  const _MacroHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00A781),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Today's Macro",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Circular Progress and Calories
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: Obx(
                      () => CircularProgressIndicator(
                    value: (ctrl.caloriesConsumed.value / ctrl.caloriesGoal.value)
                        .clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A781)),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                        () => Text(
                      ctrl.calMultiplier,
                      style: const TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Consumed / Goal Stats Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatChip(
                    label: 'consumed',
                    value: '${ctrl.caloriesConsumed.value}',
                    color: const Color(0xFF00A781),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  _StatChip(
                    label: 'goal',
                    value: '${ctrl.caloriesGoal.value}',
                    color: const Color(0xFF323232),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Macro rows (Protein / Carbs / Fats / Misc)
// ─────────────────────────────────────────────────────────────────────────────
class _MacroRow extends StatelessWidget {
  final MacroController ctrl;
  const _MacroRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        children: [
          _MacroTile(
            iconPath: 'assets/image/Margin344.png',
            label: 'Protein',
            current: ctrl.protein.value,
            goal: ctrl.proteinGoal.value,
            color: const Color(0xFF00A781),
            onTap: () => _showAddSheet(
              context, 'Add Protein', ctrl.recentProteinFoods, ctrl.addProtein,
            ),
          ),
          const SizedBox(height: 12),
          _MacroTile(
            iconPath: 'assets/image/Margin.png',
            label: 'Carbs',
            current: ctrl.carbs.value,
            goal: ctrl.carbsGoal.value,
            color: const Color(0xFFFFB300),
            onTap: () => _showAddSheet(
              context, 'Add Carbs', ctrl.recentCarbFoods, ctrl.addCarbs,
            ),
          ),
          const SizedBox(height: 12),
          _MacroTile(
            iconPath: 'assets/image/Margin34.png',
            label: 'Fats',
            current: ctrl.fats.value,
            goal: ctrl.fatsGoal.value,
            color: const Color(0xFFF44336),
            onTap: () => _showAddSheet(
              context, 'Add Fats', ctrl.recentFatFoods, ctrl.addFats,
            ),
          ),
          const SizedBox(height: 12),

      _MacroTile(
        iconPath: 'assets/image/Background.png',
        label: 'Misc',
        current: ctrl.misc.value,
        goal: ctrl.miscGoal.value,
        color: const Color(0xFF9C27B0),
        onTap: () => _showAddSheet(
          context, 'Add Fiber', ctrl.recentFiberFoods, ctrl.addMisc,
        ),
      )



        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, String title, List<MacroFood> foods, void Function(double) onAdd) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMacroSheet(title: title, recentFoods: foods, onAdd: onAdd),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String iconPath;
  final String label;
  final double current;
  final double goal;
  final Color color;
  final VoidCallback onTap;

  const _MacroTile({
    required this.iconPath,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (current / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // PNG Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              iconPath,
              width: 20,
              height: 20,
              fit: BoxFit.contain,

            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF323232),
                      ),
                    ),
                    Text(
                      '${current.toStringAsFixed(0)}g / ${goal.toStringAsFixed(0)}g',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Add Button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF00A781),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logged Meals Section
// ─────────────────────────────────────────────────────────────────────────────
class LoggedMealsSection extends StatelessWidget {
  final MacroController ctrl;
  const LoggedMealsSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section with Image and Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [

                Image.asset(
                  'assets/image/loggedicon.png',
                  width: 24,
                  height: 24,
                ),
                 SizedBox(width: 10),
                 Text(
                  'Logged Meals',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {

                ///===========================other screen to show all logged meals===========================
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF00A781),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        Obx(
              () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ctrl.loggedMeals.length,
            itemBuilder: (context, index) {
              return _MealTile(meal: ctrl.loggedMeals[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  final LoggedMeal meal;
  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meal PNG Icon
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/image/Background (1).png',

              ),
            ),
          ),
          const SizedBox(width: 16),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF323232),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today, 12:30 PM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Calorie Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00A781).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${meal.kcal} kcal',
              style: const TextStyle(
                color: Color(0xFF00A781),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Notes Section
// ─────────────────────────────────────────────────────────────────────────────
class _DailyNotesSection extends StatelessWidget {
  final MacroController ctrl;
  const _DailyNotesSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Notes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF323232),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (_) => _NotesDialog(initial: ctrl.dailyNotes.value),
            );
            if (result != null) ctrl.dailyNotes.value = result;
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(
              () => Text(
                ctrl.dailyNotes.value,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesDialog extends StatefulWidget {
  final String initial;
  const _NotesDialog({required this.initial});

  @override
  State<_NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<_NotesDialog> {
  late final TextEditingController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TextEditingController(text: widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Notes'),
      content: TextField(
        controller: _tc,
        minLines: 3,
        maxLines: 6,
        decoration: const InputDecoration(hintText: 'Write your notes…'),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A781),
          ),
          onPressed: () => Get.back(result: _tc.text),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save Routine Button
// ─────────────────────────────────────────────────────────────────────────────
class _SaveRoutineButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.snackbar(
          'Routine Saved!',
          'Your macro routine has been saved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00A781),
          colorText: Colors.white,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A781),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Save Routine',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Macro Bottom Sheet  (Add Protein / Add Carbs / Add Fats / Add Fiber)
// ─────────────────────────────────────────────────────────────────────────────
class _AddMacroSheet extends StatefulWidget {
  final String title;
  final List<MacroFood> recentFoods;
  final void Function(double) onAdd;

  const _AddMacroSheet({
    required this.title,
    required this.recentFoods,
    required this.onAdd,
  });

  @override
  State<_AddMacroSheet> createState() => _AddMacroSheetState();
}

class _AddMacroSheetState extends State<_AddMacroSheet> {
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
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFoodIndex = i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF00A781,
                                  ).withValues(alpha: 0.08)
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
                              Text(
                                food.emoji,
                                style: const TextStyle(fontSize: 22),
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
                                      food.subtitle,
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
                    const SizedBox(height: 16),

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
                      widget.onAdd(grams);
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
