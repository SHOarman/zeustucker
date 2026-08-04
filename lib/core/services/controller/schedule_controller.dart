import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeustucker/core/services/api_services/api_services.dart';
import 'package:zeustucker/core/services/controller/macro_controller.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';

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
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      combinedScore: (json['combined_score'] as num?)?.toDouble() ?? 0.0,
      workoutCompleted: (json['workout_completed'] as num?)?.toInt() ?? 0,
      workoutAssigned: (json['workout_assigned'] as num?)?.toInt() ?? 0,
      mealComponentsScored: (json['meal_components_scored'] as num?)?.toInt() ?? 0,
      dailyGoalsCompleted: (json['daily_goals_completed'] as num?)?.toInt() ?? 0,
      dailyGoalsAssigned: (json['daily_goals_assigned'] as num?)?.toInt() ?? 0,
      workoutApplicable: json['workout_applicable'] == true,
      mealApplicable: json['meal_applicable'] == true,
      dailyGoalApplicable: json['daily_goal_applicable'] == true,
      isFuture: json['is_future'] == true,
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
      userId: json['user_id']?.toString() ?? '',
      weekStart: json['week_start']?.toString() ?? '',
      weekEnd: json['week_end']?.toString() ?? '',
      dailyPoints: list
          .whereType<Map>()
          .map((x) => DailyPoint.fromJson(Map<String, dynamic>.from(x)))
          .toList(),
    );
  }
}

class WorkoutItem {
  final String id;
  final int position;
  final String instruction;
  final bool completed;
  final String? completedAt;

  WorkoutItem({
    required this.id,
    required this.position,
    required this.instruction,
    required this.completed,
    this.completedAt,
  });

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      id: json['id']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      instruction: json['instruction']?.toString() ?? '',
      completed: json['completed'] == true ||
          json['completed'] == 1 ||
          json['completed'].toString() == 'true',
      completedAt: json['completed_at']?.toString(),
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
    final items = list
        .whereType<Map>()
        .map((x) => WorkoutItem.fromJson(Map<String, dynamic>.from(x)))
        .toList();

    int assigned = (json['assigned_count'] as num?)?.toInt() ?? 0;
    if (assigned == 0) {
      assigned = items.length;
    }

    int completed = (json['completed_count'] as num?)?.toInt() ?? 0;
    if (completed == 0) {
      completed = items.where((x) => x.completed).length;
    }

    final rawScore = (json['workout_score'] as num?) ?? 0;

    return WorkoutDay(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      isFuture: json['is_future'] == true,
      applicable: json['applicable'] == true,
      workoutScore: rawScore.round(),
      completedCount: completed,
      assignedCount: assigned,
      allCompleted: json['all_completed'] == true,
      items: items,
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
      id: json['id']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      instruction: json['instruction']?.toString() ?? '',
      completed: json['completed'] == true ||
          json['completed'] == 1 ||
          json['completed'].toString() == 'true',
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
    final items = list
        .whereType<Map>()
        .map((x) => GoalItem.fromJson(Map<String, dynamic>.from(x)))
        .toList();

    int assigned = (json['assigned_count'] as num?)?.toInt() ?? 0;
    if (assigned == 0) {
      assigned = items.length;
    }

    int completed = (json['completed_count'] as num?)?.toInt() ?? 0;
    if (completed == 0) {
      completed = items.where((x) => x.completed).length;
    }

    final rawScore = (json['daily_goal_score'] as num?) ?? 0;

    return GoalDay(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      isFuture: json['is_future'] == true,
      applicable: json['applicable'] == true,
      dailyGoalScore: rawScore.round(),
      completedCount: completed,
      assignedCount: assigned,
      allCompleted: json['all_completed'] == true,
      items: items,
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

  final RxList<double> barHeights = <double>[10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0].obs;
  
  final RxInt workoutCompleted = 0.obs;
  final RxInt workoutAssigned = 0.obs;
  
  final RxInt mealsCompleted = 0.obs;
  final RxInt mealsAssigned = 7.obs;
  
  final RxInt tasksCompleted = 0.obs;
  final RxInt tasksAssigned = 0.obs;

  final RxInt todayWorkoutCompleted = 0.obs;
  final RxInt todayWorkoutAssigned = 0.obs;

  final RxInt todayTasksCompleted = 0.obs;
  final RxInt todayTasksAssigned = 0.obs;

  void syncWithHomeController() {
    if (Get.isRegistered<HomeController>()) {
      final hc = Get.find<HomeController>();
      if (hc.workoutItems.isNotEmpty) {
        todayWorkoutAssigned.value = hc.workoutItems.length;
        todayWorkoutCompleted.value = hc.workoutItems.where((x) => x.completed).length;
      }
      if (hc.todayGoals.isNotEmpty) {
        todayTasksAssigned.value = hc.todayGoals.length;
        todayTasksCompleted.value = hc.todayGoals.where((x) => x.completed).length;
      }
    }
  }

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
    syncWithHomeController();
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
            final weekday = dt.weekday;
            final index = weekday - 1;
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
        List<WorkoutDay> fetched = daysList.map((x) => WorkoutDay.fromJson(x)).toList();
        
        final List<WorkoutItem> completedItems = [];
        for (var day in fetched) {
          for (var item in day.items) {
            if (item.completed && item.completedAt != null) {
              completedItems.add(item);
            }
          }
        }


        fetched = fetched.map((day) {
          final dayDateStr = day.date.split('T')[0];
          

          final List<WorkoutItem> keptItems = day.items.where((item) {
            if (!item.completed || item.completedAt == null) return true;
            final compDateStr = item.completedAt!.split('T')[0];
            return compDateStr == dayDateStr;
          }).toList();

          final List<WorkoutItem> newlyCompletedOnThisDay = completedItems.where((item) {
            final compDateStr = item.completedAt!.split('T')[0];
            final origDayHasIt = day.items.any((x) => x.id == item.id);
            return compDateStr == dayDateStr && !origDayHasIt;
          }).toList();

          final mergedItems = [...keptItems, ...newlyCompletedOnThisDay];
          final compCount = mergedItems.where((x) => x.completed).length;
          final allComp = mergedItems.isNotEmpty && mergedItems.every((x) => x.completed);

          return WorkoutDay(
            date: day.date,
            day: day.day,
            isFuture: day.isFuture,
            applicable: day.applicable,
            workoutScore: day.workoutScore,
            completedCount: compCount,
            assignedCount: mergedItems.length,
            allCompleted: allComp,
            items: mergedItems,
          );
        }).toList();

        // Sort with today first, then past days, then future days
        _sortDays(fetched, (x) => x.date);
        weeklyWorkouts.assignAll(fetched);

        // Update totals
        workoutCompleted.value = fetched.map((x) => x.completedCount).fold(0, (a, b) => a + b);
        workoutAssigned.value = fetched.map((x) => x.assignedCount).fold(0, (a, b) => a + b);

        // Update today's totals
        final today = DateTime.now().toLocal();
        final todayDay = fetched.firstWhereOrNull((d) {
          try {
            final date = DateTime.parse(d.date).toLocal();
            return date.year == today.year && date.month == today.month && date.day == today.day;
          } catch (_) {
            return false;
          }
        });
        if (todayDay != null) {
          todayWorkoutCompleted.value = todayDay.completedCount;
          todayWorkoutAssigned.value = todayDay.assignedCount;
        } else {
          todayWorkoutCompleted.value = 0;
          todayWorkoutAssigned.value = 0;
        }
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
        
        // Sort with today first, then past days, then future days
        _sortDays(fetched, (x) => x.date);
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

      // 1. Fetch all routines to get saved notes checklist completion states
      final routinesUrl = Uri.parse(ApiServices.routines);
      final routinesResponse = await http.get(
        routinesUrl,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, Map<String, bool>> routineGoalsMap = {};
      if (routinesResponse.statusCode == 200) {
        final List<dynamic> routinesList = jsonDecode(routinesResponse.body);
        for (var r in routinesList) {
          if (r is Map) {
            final date = r['date']?.toString().split('T')[0];
            final notesStr = r['notes']?.toString() ?? '';
            if (date != null && notesStr.isNotEmpty && notesStr.startsWith('[')) {
              try {
                final List<dynamic> decodedNotes = jsonDecode(notesStr);
                final Map<String, bool> completedMap = {};
                for (var item in decodedNotes) {
                  if (item is Map) {
                    final instr = (item['instruction'] ?? item['text'])?.toString().trim();
                    final completedVal = item['completed'] == true;
                    if (instr != null && instr.isNotEmpty) {
                      completedMap[instr] = completedVal;
                    }
                  }
                }
                if (completedMap.isNotEmpty) {
                  routineGoalsMap[date] = completedMap;
                }
              } catch (_) {}
            }
          }
        }
      }

      // 2. Fetch weekly summary goals
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
        List<GoalDay> fetched = daysList.map((x) => GoalDay.fromJson(x)).toList();
        
        // Merge routine goals checked states
        fetched = fetched.map((day) {
          final dateKey = day.date.split('T')[0];
          if (routineGoalsMap.containsKey(dateKey)) {
            final completedMap = routineGoalsMap[dateKey]!;
            final updatedItems = day.items.map((goal) {
              final matchInstr = goal.instruction.trim();
              if (completedMap.containsKey(matchInstr)) {
                return GoalItem(
                  id: goal.id,
                  position: goal.position,
                  instruction: goal.instruction,
                  completed: completedMap[matchInstr]!,
                );
              }
              return goal;
            }).toList();
            
            final compCount = updatedItems.where((x) => x.completed).length;
            final allComp = updatedItems.isNotEmpty && updatedItems.every((x) => x.completed);
            
            return GoalDay(
              date: day.date,
              day: day.day,
              isFuture: day.isFuture,
              applicable: day.applicable,
              dailyGoalScore: day.dailyGoalScore,
              completedCount: compCount,
              assignedCount: day.assignedCount,
              allCompleted: allComp,
              items: updatedItems,
            );
          }
          return day;
        }).toList();

        // Sort with today first, then past days, then future days
        _sortDays(fetched, (x) => x.date);
        weeklyGoals.assignAll(fetched);

        // Update totals
        tasksCompleted.value = fetched.map((x) => x.completedCount).fold(0, (a, b) => a + b);
        tasksAssigned.value = fetched.map((x) => x.assignedCount).fold(0, (a, b) => a + b);

        // Update today's totals
        final today = DateTime.now().toLocal();
        final todayDay = fetched.firstWhereOrNull((d) {
          try {
            final date = DateTime.parse(d.date).toLocal();
            return date.year == today.year && date.month == today.month && date.day == today.day;
          } catch (_) {
            return false;
          }
        });
        if (todayDay != null) {
          todayTasksCompleted.value = todayDay.completedCount;
          todayTasksAssigned.value = todayDay.assignedCount;
        } else {
          todayTasksCompleted.value = 0;
          todayTasksAssigned.value = 0;
        }
      }
    } catch (e) {
      debugPrint("Error fetching weekly goals: $e");
    }
  }

  void _sortDays<T>(List<T> list, String Function(T) getDate) {
    final today = DateTime.now().toLocal();
    final todayDate = DateTime(today.year, today.month, today.day);

    list.sort((a, b) {
      try {
        final dA = DateTime.parse(getDate(a)).toLocal();
        final dB = DateTime.parse(getDate(b)).toLocal();
        final dtA = DateTime(dA.year, dA.month, dA.day);
        final dtB = DateTime(dB.year, dB.month, dB.day);

        final diffA = dtA.difference(todayDate).inDays;
        final diffB = dtB.difference(todayDate).inDays;

        // If one is today/past and other is future
        if (diffA <= 0 && diffB > 0) return -1;
        if (diffB <= 0 && diffA > 0) return 1;

        // If both are today/past: sort descending (newest/today first)
        if (diffA <= 0 && diffB <= 0) {
          return diffB.compareTo(diffA);
        }
        // If both are future: sort ascending (nearest future first)
        return diffA.compareTo(diffB);
      } catch (_) {
        return 0;
      }
    });
  }
}
