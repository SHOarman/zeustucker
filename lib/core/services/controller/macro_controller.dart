import 'package:get/get.dart';

class MacroFood {
  final String name;
  final String subtitle;
  final String emoji;
  MacroFood({required this.name, required this.subtitle, required this.emoji});
}

class LoggedMeal {
  final String name;
  final int kcal;
  LoggedMeal({required this.name, required this.kcal});
}

class MacroController extends GetxController {
  // ── Daily targets ──────────────────────────────────
  final RxInt caloriesConsumed = 760.obs;
  final RxInt caloriesGoal = 2000.obs;

  // ── Macros (grams) ─────────────────────────────────
  final RxDouble protein = RxDouble(45.0);
  final RxDouble proteinGoal = RxDouble(150.0);

  final RxDouble carbs = RxDouble(100.0);
  final RxDouble carbsGoal = RxDouble(250.0);

  final RxDouble fats = RxDouble(30.0);
  final RxDouble fatsGoal = RxDouble(65.0);

  final RxDouble misc = RxDouble(10.0);
  final RxDouble miscGoal = RxDouble(30.0);

  // ── Logged Meals ────────────────────────────────────
  final RxList<LoggedMeal> loggedMeals = <LoggedMeal>[
    LoggedMeal(name: 'Avocado Toast & Egg', kcal: 380),
    LoggedMeal(name: 'Mediterranean Bowl', kcal: 420),
  ].obs;

  // ── Daily Notes ─────────────────────────────────────
  final RxString dailyNotes = 'Add daily notes…'.obs;

  // ── Recent Foods lists ──────────────────────────────
  final List<MacroFood> recentProteinFoods = [
    MacroFood(
      name: 'Chicken Breast',
      subtitle: '300g • 1 serving',
      emoji: '🍗',
    ),
    MacroFood(name: 'Whey Protein', subtitle: '1 scoop', emoji: '💪'),
    MacroFood(name: 'Greek Yogurt', subtitle: '200g', emoji: '🥛'),
  ];

  final List<MacroFood> recentCarbFoods = [
    MacroFood(name: 'Brown Rice', subtitle: '1 cup • 1 serving', emoji: '🍚'),
    MacroFood(name: 'Banana', subtitle: '1 medium', emoji: '🍌'),
    MacroFood(name: 'Sweet Potato', subtitle: '150g', emoji: '🍠'),
    MacroFood(name: 'Oatmeal', subtitle: '100g • 1 serving', emoji: '🥣'),
  ];

  final List<MacroFood> recentFatFoods = [
    MacroFood(name: 'Avocado', subtitle: '1/2 whole', emoji: '🥑'),
    MacroFood(name: 'Extra Virgin Olive Oil', subtitle: '1 tbsp', emoji: '🫒'),
    MacroFood(name: 'Raw Almonds', subtitle: '30g', emoji: '🌰'),
  ];

  final List<MacroFood> recentFiberFoods = [
    MacroFood(name: 'Broccoli', subtitle: '150g • 1 cup', emoji: '🥦'),
    MacroFood(name: 'Chia Seeds', subtitle: '2 tbsp', emoji: '🌱'),
    MacroFood(name: 'Raspberries', subtitle: '1 cup', emoji: '🫐'),
    MacroFood(name: 'Lentils', subtitle: '1/2 cup • 100g', emoji: '🟤'),
  ];

  // ── Add macro helpers ───────────────────────────────
  void addProtein(double grams) {
    protein.value += grams;
    caloriesConsumed.value += (grams * 4).round();
  }

  void addCarbs(double grams) {
    carbs.value += grams;
    caloriesConsumed.value += (grams * 4).round();
  }

  void addFats(double grams) {
    fats.value += grams;
    caloriesConsumed.value += (grams * 9).round();
  }

  void addMisc(double grams) {
    misc.value += grams;
    caloriesConsumed.value += (grams * 2).round();
  }

  // ── Multiplier text ─────────────────────────────────
  String get calMultiplier {
    final ratio = caloriesConsumed.value / caloriesGoal.value;
    return '${caloriesConsumed.value} × ${(ratio * 100).toStringAsFixed(0)}';
  }
}
