import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../api_services/api_services.dart';

class Createroutine extends GetxController {
  // Input fields
  final exerciseController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatsController = TextEditingController();
  final fiberController = TextEditingController();
  final waterGoalController = TextEditingController();
  final dailyGoalInputController = TextEditingController();

  // Client details
  var clientId = ''.obs;
  var clientName = ''.obs;
  var clientImage = ''.obs;
  var isCreateMode = false.obs;

  // Exercises & Dynamic Daily Goals lists
  var exercises = <String>[].obs;
  var dailyGoals = <String>[].obs;

  var isLoading = false.obs;
  final RxString nutritionPlanId = ''.obs;
  final RxString routineId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Parse arguments passed from Manageclients screen
    final args = Get.arguments;
    if (args is Map) {
      clientId.value = args['id']?.toString() ?? '';
      clientName.value = args['name']?.toString() ?? 'Client';
      clientImage.value = args['imageUrl']?.toString() ?? 'assets/image/newprofile.png';
      isCreateMode.value = args['isCreate'] ?? false;
    } else {
      clientId.value = '';
      clientName.value = 'Client';
      clientImage.value = 'assets/image/newprofile.png';
      isCreateMode.value = false;
    }

    // Initialize fields
    exercises.clear();
    dailyGoals.clear();
    caloriesController.clear();
    proteinController.clear();
    carbsController.clear();
    fatsController.clear();
    fiberController.clear();
    waterGoalController.clear();
    dailyGoalInputController.clear();

    // Fetch existing routine for client
    fetchClientRoutine();
  }

  @override
  void onClose() {
    exerciseController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();
    fiberController.dispose();
    waterGoalController.dispose();
    dailyGoalInputController.dispose();
    super.onClose();
  }

  void addExercise() {
    final text = exerciseController.text.trim();
    if (text.isNotEmpty) {
      exercises.add(text);
      exerciseController.clear();
    }
  }

  void removeExercise(int index) {
    if (index >= 0 && index < exercises.length) {
      exercises.removeAt(index);
    }
  }

  void addDailyGoal() {
    final text = dailyGoalInputController.text.trim();
    if (text.isNotEmpty) {
      dailyGoals.add(text);
      dailyGoalInputController.clear();
    }
  }

  void removeDailyGoal(int index) {
    if (index >= 0 && index < dailyGoals.length) {
      dailyGoals.removeAt(index);
    }
  }

  void _parseNotesGoals(dynamic goalsData) {
    if (goalsData == null) return;
    try {
      final decoded = goalsData is String ? jsonDecode(goalsData) : goalsData;
      if (decoded is List) {
        final parsed = decoded.map((e) => e?.toString().trim() ?? '').where((e) => e.isNotEmpty).toList();
        if (parsed.isNotEmpty) {
          dailyGoals.value = parsed;
          return;
        }
      }
      if (decoded is Map) {
        final List<String> extracted = [];
        decoded.forEach((key, val) {
          if (val == true) {
            extracted.add(key.toString());
          }
        });
        if (extracted.isNotEmpty) {
          dailyGoals.value = extracted;
          return;
        }
      }
      if (goalsData is String && goalsData.trim().isNotEmpty) {
        dailyGoals.value = [goalsData.trim()];
      }
    } catch (_) {
      if (goalsData != null && goalsData.toString().trim().isNotEmpty) {
        dailyGoals.value = [goalsData.toString().trim()];
      }
    }
  }

  Future<void> fetchClientRoutine() async {
    if (clientId.isEmpty) return;

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

      nutritionPlanId.value = '';
      routineId.value = '';
      exercises.clear();
      dailyGoals.clear();

      final nutritionUrl = Uri.parse(ApiServices.coachNutritionPlans);
      debugPrint("\n==========================================================================");
      debugPrint(">>> FETCHING ROUTINE/NUTRITION PLAN FOR CLIENT");
      debugPrint("Client Name: ${clientName.value}");
      debugPrint("Client ID:   ${clientId.value}");
      debugPrint("API URL:     $nutritionUrl");
      debugPrint("==========================================================================");

      final response = await http.get(nutritionUrl, headers: headers);
      debugPrint("<<< NUTRITION PLANS RESPONSE STATUS: ${response.statusCode}");
      debugPrint("<<< RAW RESPONSE BODY:\n${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        final targetClientId = clientId.value.trim().toLowerCase();
        
        final clientPlans = list.where(
          (element) => element['client_id']?.toString().trim().toLowerCase() == targetClientId,
        ).toList();

        // Sort by updated_at / created_at or pick last to get the latest plan
        if (clientPlans.length > 1) {
          clientPlans.sort((a, b) {
            final aTime = a['updated_at'] ?? a['created_at'] ?? '';
            final bTime = b['updated_at'] ?? b['created_at'] ?? '';
            return aTime.toString().compareTo(bTime.toString());
          });
        }

        final plan = clientPlans.isNotEmpty ? clientPlans.last : null;

        if (plan != null) {
          nutritionPlanId.value = plan['id']?.toString() ?? '';

          String formatNum(dynamic val) {
            if (val == null || val == 'null' || val == 'None') return '';
            final str = val.toString().trim();
            if (str.isEmpty || str == 'null' || str == 'None') return '';
            final n = num.tryParse(str);
            if (n == null) return str == 'null' ? '' : str;
            if (n == 0) return '';
            return (n % 1 == 0) ? n.toInt().toString() : n.toString();
          }

          caloriesController.text = formatNum(plan['daily_calories'] ?? plan['calories']);
          proteinController.text = formatNum(plan['protein']);
          carbsController.text = formatNum(plan['carbs']);
          fatsController.text = formatNum(plan['fat'] ?? plan['fats']);
          fiberController.text = formatNum(plan['fiber']);

          // Workout plan exercises list
          final wPlan = plan['workout_plan'] ?? plan['exercises'] ?? plan['workout'];
          if (wPlan is List) {
            exercises.value = wPlan.map((e) => e.toString()).where((e) => e.trim().isNotEmpty && e != 'null').toList();
          } else if (wPlan != null && wPlan.toString().isNotEmpty) {
            try {
              final decoded = jsonDecode(wPlan.toString());
              if (decoded is List) {
                exercises.value = decoded.map((e) => e.toString()).where((e) => e.trim().isNotEmpty && e != 'null').toList();
              } else {
                final str = wPlan.toString().trim();
                if (str.isNotEmpty && str != 'null') exercises.value = [str];
              }
            } catch (_) {
              final str = wPlan.toString().trim();
              if (str.isNotEmpty && str != 'null') exercises.value = [str];
            }
          }

          // Daily goals list
          final dGoals = plan['daily_goals'] ?? plan['notes'] ?? plan['goals'];
          if (dGoals is List) {
            dailyGoals.value = dGoals.map((e) => e.toString()).where((e) => e.trim().isNotEmpty && e != 'null').toList();
          } else if (dGoals != null) {
            _parseNotesGoals(dGoals);
          }

          debugPrint("\n================ GET SUCCESS: PARSED DATA FOR ${clientName.value} ================");
          debugPrint("Nutrition Plan ID: ${nutritionPlanId.value}");
          debugPrint("Calories (KCAL):   ${caloriesController.text}");
          debugPrint("Protein (G):       ${proteinController.text}");
          debugPrint("Carbs (G):         ${carbsController.text}");
          debugPrint("Fats (G):          ${fatsController.text}");
          debugPrint("Fiber (G):         ${fiberController.text}");
          debugPrint("Workout Plan:      ${exercises.toList()}");
          debugPrint("Daily Goals:       ${dailyGoals.toList()}");
          debugPrint("====================================================================================\n");
        } else {
          debugPrint("\n⚠️ NO SAVED ROUTINE FOUND FOR CLIENT: ${clientName.value} (${clientId.value})\n");
        }
      }
    } catch (e) {
      debugPrint("Error fetching client routine: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRoutine() async {
    if (clientId.isEmpty) {
      Get.snackbar("Error", "No client selected for routine.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Show loading spinner dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00B171),
        ),
      ),
      barrierDismissible: false,
    );

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userRole = prefs.getString('role')?.toUpperCase() ?? 'COACH';

      if (token == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar("Error", "Authentication token not found.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Auto add unsubmitted exercise text if present
      final unsavedExercise = exerciseController.text.trim();
      if (unsavedExercise.isNotEmpty) {
        exercises.add(unsavedExercise);
        exerciseController.clear();
      }

      // Auto add unsubmitted daily goal text if present
      final unsavedGoal = dailyGoalInputController.text.trim();
      if (unsavedGoal.isNotEmpty) {
        dailyGoals.add(unsavedGoal);
        dailyGoalInputController.clear();
      }

      final int calories = int.tryParse(caloriesController.text) ?? 0;
      final int protein = int.tryParse(proteinController.text) ?? 0;
      final int carbs = int.tryParse(carbsController.text) ?? 0;
      final int fats = int.tryParse(fatsController.text) ?? 0;
      final int fiber = int.tryParse(fiberController.text) ?? 0;
      final double waterGoal = double.tryParse(waterGoalController.text) ?? 0.0;

      final dateStr = DateTime.now().toUtc().toIso8601String().split('T')[0];

      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // 1. Submit Coach Nutrition & Workout Plan (Primary endpoint for Coach)
      http.Response nutritionResponse;
      final nutritionBodyMap = {
        "client_id": clientId.value,
        "daily_calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fats,
        "fiber": fiber,
        "water_goal": waterGoal,
        "workout_plan": exercises.toList(),
        "daily_goals": dailyGoals.toList(),
        "notes": jsonEncode(dailyGoals.toList()),
        "date": dateStr,
      };

      if (nutritionPlanId.value.isNotEmpty) {
        final nutritionPutUrl = Uri.parse("${ApiServices.coachNutritionPlans}/${nutritionPlanId.value}");
        debugPrint(">>> UPDATING NUTRITION PLAN: PUT $nutritionPutUrl");
        nutritionResponse = await http.put(
          nutritionPutUrl,
          headers: headers,
          body: jsonEncode(nutritionBodyMap),
        );
      } else {
        final nutritionPostUrl = Uri.parse(ApiServices.coachNutritionPlans);
        debugPrint(">>> CREATING NUTRITION PLAN: POST $nutritionPostUrl");
        nutritionResponse = await http.post(
          nutritionPostUrl,
          headers: headers,
          body: jsonEncode(nutritionBodyMap),
        );
      }

      debugPrint("<<< NUTRITION PLAN STATUS: ${nutritionResponse.statusCode}");
      debugPrint("<<< NUTRITION PLAN BODY: ${nutritionResponse.body}");

      // 2. Secondary sync to /routines (Only if user has SELF role)
      if (userRole == 'SELF') {
        try {
          final body = jsonEncode({
            "date": dateStr,
            "goal_kcal": calories,
            "goal_protein": protein,
            "goal_carbs": carbs,
            "goal_fats": fats,
            "goal_fiber": fiber,
            "water_goal": waterGoal,
            "workout": jsonEncode(exercises.toList()),
            "notes": jsonEncode(dailyGoals.toList()),
            "client_id": clientId.value,
            "calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fats": fats,
            "fiber": fiber,
            "exercises": exercises.toList(),
            "daily_goals": dailyGoals.toList(),
          });

          if (routineId.value.isNotEmpty) {
            final routinesPutUrl = Uri.parse("${ApiServices.routines}/${routineId.value}");
            debugPrint(">>> UPDATING ROUTINE: PUT $routinesPutUrl");
            await http.put(
              routinesPutUrl,
              headers: headers,
              body: jsonEncode({
                "date": dateStr,
                "goal_kcal": calories,
                "goal_protein": protein,
                "goal_carbs": carbs,
                "goal_fats": fats,
                "goal_fiber": fiber,
                "water_goal": waterGoal,
                "workout": jsonEncode(exercises.toList()),
                "notes": jsonEncode(dailyGoals.toList()),
                "completion_status": false,
              }),
            );
          } else {
            final routinesPostUrl = Uri.parse("${ApiServices.routines}?client_id=${clientId.value}");
            debugPrint(">>> CREATING ROUTINE: POST $routinesPostUrl");
            await http.post(routinesPostUrl, headers: headers, body: body);
          }
        } catch (e) {
          debugPrint("Secondary routine sync skipped/failed: $e");
        }
      }

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (nutritionResponse.statusCode == 200 || nutritionResponse.statusCode == 201) {
        Get.snackbar("Success", "Routine & Nutrition plan saved successfully!",
            backgroundColor: const Color(0xFF00B171), colorText: Colors.white);
        Get.offNamed(AppRoutes.adminhome);
      } else if (nutritionResponse.statusCode == 500) {
        Get.snackbar("Server Error (500)", "Backend Database Error: 'nutrition_plans.fiber' column missing in SQLite database.",
            backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
      } else {
        Get.snackbar("Error", "Failed to save routine: ${nutritionResponse.statusCode}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint("Error submitting routine: $e");
      Get.snackbar("Error", "An error occurred: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}