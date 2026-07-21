import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeustucker/core/services/api_services/api_services.dart';

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
  final RxInt caloriesConsumed = 0.obs;
  final RxInt caloriesGoal = 0.obs;

  // ── Macros (grams) ─────────────────────────────────
  final RxDouble protein = RxDouble(0.0);
  final RxDouble proteinGoal = RxDouble(0.0);

  final RxDouble carbs = RxDouble(0.0);
  final RxDouble carbsGoal = RxDouble(0.0);

  final RxDouble fats = RxDouble(0.0);
  final RxDouble fatsGoal = RxDouble(0.0);

  final RxDouble misc = RxDouble(0.0);
  final RxDouble miscGoal = RxDouble(0.0);

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMacroTargets();
  }

  int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    final n = num.tryParse(val.toString());
    if (n == null) return fallback;
    return n.toInt();
  }

  double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    final n = num.tryParse(val.toString());
    if (n == null) return fallback;
    return n.toDouble();
  }

  Future<void> fetchMacroTargets() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // 1. Try GET /coach/nutrition-plans
      try {
        final nutritionUrl = Uri.parse(ApiServices.coachNutritionPlans);
        debugPrint(">>> FETCHING MACRO TARGETS FROM NUTRITION PLANS: $nutritionUrl");
        final response = await http.get(nutritionUrl, headers: headers);
        debugPrint("<<< MACRO NUTRITION PLANS STATUS: ${response.statusCode}");

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          if (list.isNotEmpty) {
            final sortedList = List<dynamic>.from(list);
            sortedList.sort((a, b) {
              final aTime = a['updated_at'] ?? a['created_at'] ?? '';
              final bTime = b['updated_at'] ?? b['created_at'] ?? '';
              return aTime.toString().compareTo(bTime.toString());
            });

            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getString('user_id') ?? '';

            dynamic plan;
            if (userId.isNotEmpty) {
              final userPlans = sortedList.where((p) =>
                p['client_id']?.toString().toLowerCase() == userId.toLowerCase() ||
                p['user_id']?.toString().toLowerCase() == userId.toLowerCase()
              ).toList();
              if (userPlans.isNotEmpty) {
                plan = userPlans.last;
              }
            }

            plan ??= sortedList.last;
            debugPrint("Loaded macro targets from latest plan: $plan");

            caloriesGoal.value = _parseInt(plan['daily_calories'] ?? plan['calories'], 0);
            proteinGoal.value = _parseDouble(plan['protein'], 0.0);
            carbsGoal.value = _parseDouble(plan['carbs'], 0.0);
            fatsGoal.value = _parseDouble(plan['fat'] ?? plan['fats'], 0.0);
            miscGoal.value = _parseDouble(plan['fiber'], 0.0);
            return;
          }
        }
      } catch (e) {
        debugPrint("Error fetching nutrition plans for macros: $e");
      }

      try {
        final dashboardUrl = Uri.parse(ApiServices.dashboard);
        debugPrint(">>> FETCHING MACRO TARGETS FROM DASHBOARD: $dashboardUrl");
        final dashboardResponse = await http.get(dashboardUrl, headers: headers);
        if (dashboardResponse.statusCode == 200) {
          final data = jsonDecode(dashboardResponse.body);
          final clientDashboard = data['client_dashboard'];
          if (clientDashboard != null) {
            final todayRoutine = clientDashboard['today_routine'];
            if (todayRoutine != null) {
              caloriesGoal.value = _parseInt(todayRoutine['goal_kcal'] ?? todayRoutine['calories'], 0);
              proteinGoal.value = _parseDouble(todayRoutine['goal_protein'] ?? todayRoutine['protein'], 0.0);
              carbsGoal.value = _parseDouble(todayRoutine['goal_carbs'] ?? todayRoutine['carbs'], 0.0);
              fatsGoal.value = _parseDouble(todayRoutine['goal_fats'] ?? todayRoutine['fat'], 0.0);
              miscGoal.value = _parseDouble(todayRoutine['goal_fiber'] ?? todayRoutine['fiber'], 0.0);
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching dashboard for macros: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  final RxList<LoggedMeal> loggedMeals = <LoggedMeal>[].obs;

  final RxString dailyNotes = ''.obs;

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
    final ratio = caloriesGoal.value > 0 ? caloriesConsumed.value / caloriesGoal.value : 0.0;
    return '${caloriesConsumed.value} × ${(ratio * 100).toStringAsFixed(0)}';
  }
}
