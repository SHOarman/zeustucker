import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/macro_controller.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';
import 'package:zeustucker/presention/userinterface/stats/widget/add_macro_sheet.dart';
import 'package:zeustucker/presention/userinterface/stats/widget/notes_dialog.dart';

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
            _SaveRoutineButton(ctrl: ctrl),
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
              context, 'Add Protein', ctrl.loggedMeals,
              onAdd: (grams, {foodName, logId}) => ctrl.addProtein(grams, foodName: foodName, logId: logId),
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
              context, 'Add Carbs', ctrl.loggedMeals,
              onAdd: (grams, {foodName, logId}) => ctrl.addCarbs(grams, foodName: foodName, logId: logId),
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
              context, 'Add Fats', ctrl.loggedMeals,
              onAdd: (grams, {foodName, logId}) => ctrl.addFats(grams, foodName: foodName, logId: logId),
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
              context, 'Add Fiber', ctrl.loggedMeals,
              onAdd: (grams, {foodName, logId}) => ctrl.addMisc(grams, foodName: foodName, logId: logId),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(
    BuildContext context,
    String title,
    List<LoggedMeal> foods, {
    required void Function(double grams, {String? foodName, String? logId}) onAdd,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMacroSheet(title: title, recentFoods: foods, onAdd: onAdd),
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

    double multiplier = 4.0;
    final labelLower = label.toLowerCase();
    if (labelLower.contains('fat')) {
      multiplier = 9.0;
    } else if (labelLower.contains('fiber') || labelLower.contains('misc')) {
      multiplier = 2.0;
    }

    final currentKcal = current * multiplier;
    final goalKcal = goal * multiplier;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              color: color.withValues(alpha: 0.1),
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
                      '${currentKcal.toStringAsFixed(0)} kcal / ${goalKcal.toStringAsFixed(0)} kcal',
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
class LoggedMealsSection extends StatefulWidget {
  final MacroController ctrl;
  const LoggedMealsSection({super.key, required this.ctrl});

  @override
  State<LoggedMealsSection> createState() => _LoggedMealsSectionState();
}

class _LoggedMealsSectionState extends State<LoggedMealsSection> {
  String _selectedMealType = 'BREAKFAST';
  late final TextEditingController _foodNameCtrl;
  late final TextEditingController _kcalCtrl;

  @override
  void initState() {
    super.initState();
    _foodNameCtrl = TextEditingController();
    _kcalCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _foodNameCtrl.dispose();
    _kcalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitMealLog() async {
    final foodName = _foodNameCtrl.text.trim();
    final kcalText = _kcalCtrl.text.trim();

    if (foodName.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a food name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (kcalText.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter kcal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final kcal = int.tryParse(kcalText) ?? 0;

    // Call addCustomMealLog to update local state immediately and log the meal
    widget.ctrl.addCustomMealLog(
      mealType: _selectedMealType,
      foodName: foodName,
      amount: 1.0,
      amountUnit: 'serving',
      kcal: kcal,
      proteinVal: 0.0,
      carbsVal: 0.0,
      fatVal: 0.0,
      fiberVal: 0.0,
    );

    // Clear input fields
    _foodNameCtrl.clear();
    _kcalCtrl.clear();
    
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

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
                const SizedBox(width: 10),
                const Text(
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
        const SizedBox(height: 8),

        // Inline Form Card (Styled like Daily Notes Card)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Dropdown for Meal Type
              Row(
                children: [
                  const Text(
                    'Meal Type: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: _selectedMealType,
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF666666), size: 20),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF323232),
                          fontWeight: FontWeight.w600,
                        ),
                        items: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK']
                            .map((val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(
                                    val,
                                    style: const TextStyle(
                                      color: Color(0xFF323232),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMealType = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16, color: Color(0xFFEEEEEE)),
              // Row 2: Food Name & Kcal & Log Button
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _foodNameCtrl,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF323232),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Food Name',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 1,
                    height: 20,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _kcalCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF323232),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Kcal',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _submitMealLog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A781),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Log',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List of Logged Meals
        Obx(() {
          if (widget.ctrl.loggedMeals.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: Colors.grey[300],
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No meals logged today',
                    style: TextStyle(
                      color: Color(0xFF323232),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Use the form above or the "+" buttons to log a meal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.ctrl.loggedMeals.length,
            itemBuilder: (context, index) {
              return _MealTile(meal: widget.ctrl.loggedMeals[index]);
            },
          );
        }),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  final LoggedMeal meal;
  const _MealTile({required this.meal});

  String _formatTime(String? loggedAt) {
    if (loggedAt == null || loggedAt.isEmpty) return 'Today';
    try {
      final dateTime = DateTime.parse(loggedAt).toLocal();
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return 'Today';
    }
  }

  Color _getMealTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'BREAKFAST':
        return const Color(0xFF00A781);
      case 'LUNCH':
        return const Color(0xFFFFB300);
      case 'DINNER':
        return const Color(0xFFF44336);
      case 'SNACK':
      default:
        return const Color(0xFF9C27B0);
    }
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getMealTypeColor(meal.mealType);
    final amountText = meal.amount != null
        ? '${meal.amount!.toStringAsFixed(0)} ${meal.amountUnit ?? "serving"}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meal PNG Icon / Colored dot container
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.restaurant_menu,
              color: typeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meal.mealType?.toUpperCase() ?? 'MEAL',
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(meal.loggedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF323232),
                  ),
                ),
                if (amountText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    amountText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                // Display macros in a small Row if present
                if ((meal.protein ?? 0) > 0 || (meal.carbs ?? 0) > 0 || (meal.fat ?? 0) > 0 || (meal.fiber ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if ((meal.protein ?? 0) > 0)
                        _buildMacroChip('P: ${meal.protein!.toStringAsFixed(0)}g', const Color(0xFF00A781)),
                      if ((meal.carbs ?? 0) > 0)
                        _buildMacroChip('C: ${meal.carbs!.toStringAsFixed(0)}g', const Color(0xFFFFB300)),
                      if ((meal.fat ?? 0) > 0)
                        _buildMacroChip('F: ${meal.fat!.toStringAsFixed(0)}g', const Color(0xFFF44336)),
                      if ((meal.fiber ?? 0) > 0)
                        _buildMacroChip('Fi: ${meal.fiber!.toStringAsFixed(0)}g', const Color(0xFF9C27B0)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Calories display
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${meal.kcal}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF323232),
                ),
              ),
              const Text(
                'kcal',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
              builder: (_) => NotesDialog(initial: ctrl.dailyNotes.value),
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
                ctrl.dailyNotes.value.isEmpty ? 'Write your notes...' : ctrl.dailyNotes.value,
                style: TextStyle(
                  color: ctrl.dailyNotes.value.isEmpty ? Colors.grey[400] : Colors.grey[800],
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Save Routine Button
// ─────────────────────────────────────────────────────────────────────────────
class _SaveRoutineButton extends StatelessWidget {
  final MacroController ctrl;
  const _SaveRoutineButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: ctrl.isLoading.value ? null : () => ctrl.saveRoutine(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A781),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          child: ctrl.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}




