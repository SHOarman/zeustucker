import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeustucker/core/services/api_services/api_services.dart';
import 'package:zeustucker/core/services/controller/macro_controller.dart';

// ── DailyPoint/WeeklySummary models (for graph) ───────────────────────────
class DailyPoint {
  final String date;
  final String day;
  final double combinedScore;
  final int workoutCompleted;
  final int workoutAssigned;
  final int mealComponentsScored;
  final int dailyGoalsCompleted;
  final int dailyGoalsAssigned;
  final bool workoutApplicable;
  final bool mealApplicable;
  final bool dailyGoalApplicable;
  final bool isFuture;

  DailyPoint({
    required this.date,
    required this.day,
    required this.combinedScore,
    required this.workoutCompleted,
    required this.workoutAssigned,
    required this.mealComponentsScored,
    required this.dailyGoalsCompleted,
    required this.dailyGoalsAssigned,
    required this.workoutApplicable,
    required this.mealApplicable,
    required this.dailyGoalApplicable,
    required this.isFuture,
  });

  factory DailyPoint.fromJson(Map<String, dynamic> json) {
    return DailyPoint(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      combinedScore: (json['combined_score'] ?? 0.0).toDouble(),
      workoutCompleted: json['workout_completed'] ?? 0,
      workoutAssigned: json['workout_assigned'] ?? 0,
      mealComponentsScored: json['meal_components_scored'] ?? 0,
      dailyGoalsCompleted: json['daily_goals_completed'] ?? 0,
      dailyGoalsAssigned: json['daily_goals_assigned'] ?? 0,
      workoutApplicable: json['workout_applicable'] ?? false,
      mealApplicable: json['meal_applicable'] ?? false,
      dailyGoalApplicable: json['daily_goal_applicable'] ?? false,
      isFuture: json['is_future'] ?? false,
    );
  }
}

class WeeklySummary {
  final String userId;
  final String weekStart;
  final String weekEnd;
  final List<DailyPoint> dailyPoints;

  WeeklySummary({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.dailyPoints,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    final list = json['daily_points'] as List? ?? [];
    return WeeklySummary(
      userId: json['user_id'] ?? '',
      weekStart: json['week_start'] ?? '',
      weekEnd: json['week_end'] ?? '',
      dailyPoints: list.map((x) => DailyPoint.fromJson(x)).toList(),
    );
  }
}

class WorkoutItem {
  final String id;
  final int position;
  final String instruction;
  final bool completed;

  WorkoutItem({
    required this.id,
    required this.position,
    required this.instruction,
    required this.completed,
  });

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      id: json['id'] ?? '',
      position: (json['position'] ?? 0) is num ? (json['position'] as num).toInt() : 0,
      instruction: json['instruction'] ?? '',
      completed: json['completed'] == true || json['completed'] == 1 || json['completed'].toString() == 'true',
    );
  }
}

class WorkoutDay {
  final String date;
  final String day;
  final bool isFuture;
  final bool applicable;
  final int workoutScore;
  final int completedCount;
  final int assignedCount;
  final bool allCompleted;
  final List<WorkoutItem> items;

  WorkoutDay({
    required this.date,
    required this.day,
    required this.isFuture,
    required this.applicable,
    required this.workoutScore,
    required this.completedCount,
    required this.assignedCount,
    required this.allCompleted,
    required this.items,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? [];
    final items = list.map((x) => WorkoutItem.fromJson(x)).toList();

    int assigned = json['assigned_count'] ?? 0;
    if (assigned == 0) {
      assigned = items.length;
    }

    int completed = json['completed_count'] ?? 0;
    if (completed == 0) {
      completed = items.where((x) => x.completed).length;
    }

    return WorkoutDay(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      isFuture: json['is_future'] ?? false,
      applicable: json['applicable'] ?? false,
      workoutScore: json['workout_score'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      assignedCount: json['assigned_count'] ?? 0,
      allCompleted: json['all_completed'] ?? false,
      items: list.map((x) => WorkoutItem.fromJson(x)).toList(),
    );
  }
}

// ── Goals models ───────────────────────────────────────────────────────────
class GoalItem {
  final String id;
  final int position;
  final String instruction;
  final bool completed;

  GoalItem({
    required this.id,
    required this.position,
    required this.instruction,
    required this.completed,
  });

  factory GoalItem.fromJson(Map<String, dynamic> json) {
    return GoalItem(
      id: json['id'] ?? '',
      position: json['position'] ?? 0,
      instruction: json['instruction'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}

class GoalDay {
  final String date;
  final String day;
  final bool isFuture;
  final bool applicable;
  final int dailyGoalScore;
  final int completedCount;
  final int assignedCount;
  final bool allCompleted;
  final List<GoalItem> items;

  GoalDay({
    required this.date,
    required this.day,
    required this.isFuture,
    required this.applicable,
    required this.dailyGoalScore,
    required this.completedCount,
    required this.assignedCount,
    required this.allCompleted,
    required this.items,
  });

  factory GoalDay.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? [];
    return GoalDay(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      isFuture: json['is_future'] ?? false,
      applicable: json['applicable'] ?? false,
      dailyGoalScore: json['daily_goal_score'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      assignedCount: json['assigned_count'] ?? 0,
      allCompleted: json['all_completed'] ?? false,
      items: list.map((x) => GoalItem.fromJson(x)).toList(),
    );
  }
}

// ── Meals models ───────────────────────────────────────────────────────────
class MealMacro {
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double water;

  MealMacro({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.water,
  });

  factory MealMacro.fromJson(Map<String, dynamic> json) {
    return MealMacro(
      kcal: (json['kcal'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      fiber: (json['fiber'] ?? 0.0).toDouble(),
      water: (json['water'] ?? 0.0).toDouble(),
    );
  }
}

class MealDay {
  final String date;
  final String day;
  final bool isFuture;
  final bool applicable;
  final MealMacro targets;
  final MealMacro consumed;
  final MealMacro remaining;
  final List<LoggedMeal> loggedMeals;

  MealDay({
    required this.date,
    required this.day,
    required this.isFuture,
    required this.applicable,
    required this.targets,
    required this.consumed,
    required this.remaining,
    required this.loggedMeals,
  });

  factory MealDay.fromJson(Map<String, dynamic> json) {
    final list = json['logged_meals'] as List? ?? [];
    final loggedMeals = list.map((x) => LoggedMeal.fromJson(x)).toList();

    double sumKcal = 0;
    double sumProtein = 0;
    double sumCarbs = 0;
    double sumFat = 0;
    double sumFiber = 0;
    double sumWater = 0;

    for (var meal in loggedMeals) {
      sumKcal += meal.kcal;
      sumProtein += meal.protein ?? 0.0;
      sumCarbs += meal.carbs ?? 0.0;
      sumFat += meal.fat ?? 0.0;
      sumFiber += meal.fiber ?? 0.0;
    }

    final computedConsumed = MealMacro(
      kcal: sumKcal,
      protein: sumProtein,
      carbs: sumCarbs,
      fat: sumFat,
      fiber: sumFiber,
      water: sumWater,
    );

    return MealDay(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      isFuture: json['is_future'] ?? false,
      applicable: json['applicable'] ?? false,
      targets: MealMacro.fromJson(json['targets'] ?? {}),
      consumed: computedConsumed,
      remaining: MealMacro.fromJson(json['remaining'] ?? {}),
      loggedMeals: loggedMeals,
    );
  }
}

class ScheduleController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<WeeklySummary?> weeklySummary = Rx<WeeklySummary?>(null);

  // Lists for detail pages
  final RxList<WorkoutDay> weeklyWorkouts = <WorkoutDay>[].obs;
  final RxList<MealDay> weeklyMeals = <MealDay>[].obs;
  final RxList<GoalDay> weeklyGoals = <GoalDay>[].obs;

  // Observables for the bar heights
  final RxList<double> barHeights = <double>[10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0].obs;
  
  // Observables for metric cards
  final RxInt workoutCompleted = 0.obs;
  final RxInt workoutAssigned = 0.obs;
  
  final RxInt mealsCompleted = 0.obs;
  final RxInt mealsAssigned = 7.obs;
  
  final RxInt tasksCompleted = 0.obs;
  final RxInt tasksAssigned = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await fetchWeeklySummary();
    await fetchWeeklyWorkouts();
    await fetchWeeklyMeals();
    await fetchWeeklyGoals();
  }

  Future<void> fetchWeeklySummary() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse("${ApiServices.baseUrl}/weekly-summary");
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Weekly Summary Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = WeeklySummary.fromJson(data);
        weeklySummary.value = summary;

        final newHeights = List<double>.filled(7, 10.0);
        for (var point in summary.dailyPoints) {
          try {
            final dt = DateTime.parse(point.date);
            final weekday = dt.weekday; // 1 = Mon, 7 = Sun
            final index = weekday - 1; // 0 = Mon, 6 = Sun
            if (index >= 0 && index < 7) {
              final score = point.combinedScore;
              final h = (score / 100.0) * 250.0;
              newHeights[index] = h.clamp(10.0, 250.0);
            }
          } catch (_) {}
        }
        barHeights.assignAll(newHeights);
      }
    } catch (e) {
      debugPrint("Error fetching weekly summary: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeeklyWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.weeklySummaryWorkouts);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Weekly Workouts Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> daysList = data['days'] ?? [];
        final fetched = daysList.map((x) => WorkoutDay.fromJson(x)).toList();
        
        // Sort chronologically
        fetched.sort((a, b) => a.date.compareTo(b.date));
        weeklyWorkouts.assignAll(fetched);

        // Update totals
        workoutCompleted.value = fetched.map((x) => x.completedCount).fold(0, (a, b) => a + b);
        workoutAssigned.value = fetched.map((x) => x.assignedCount).fold(0, (a, b) => a + b);
      }
    } catch (e) {
      debugPrint("Error fetching weekly workouts: $e");
    }
  }

  Future<void> fetchWeeklyMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.weeklySummaryMeals);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Weekly Meals Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> daysList = data['days'] ?? [];
        final fetched = daysList.map((x) => MealDay.fromJson(x)).toList();
        
        // Sort chronologically
        fetched.sort((a, b) => a.date.compareTo(b.date));
        weeklyMeals.assignAll(fetched);

        // Meal completion status is how many days have targets & met them or logged > 0 kcal
        mealsCompleted.value = fetched.where((x) => x.consumed.kcal > 0).length;
        mealsAssigned.value = fetched.length > 0 ? fetched.length : 7;
      }
    } catch (e) {
      debugPrint("Error fetching weekly meals: $e");
    }
  }

  Future<void> fetchWeeklyGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.weeklySummaryGoals);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Weekly Goals Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> daysList = data['days'] ?? [];
        final fetched = daysList.map((x) => GoalDay.fromJson(x)).toList();
        
        // Sort chronologically
        fetched.sort((a, b) => a.date.compareTo(b.date));
        weeklyGoals.assignAll(fetched);

        // Update totals
        tasksCompleted.value = fetched.map((x) => x.completedCount).fold(0, (a, b) => a + b);
        tasksAssigned.value = fetched.map((x) => x.assignedCount).fold(0, (a, b) => a + b);
      }
    } catch (e) {
      debugPrint("Error fetching weekly goals: $e");
    }
  }
}
