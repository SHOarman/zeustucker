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

  // Client details
  var clientId = ''.obs;
  var clientName = ''.obs;
  var clientImage = ''.obs;
  var isCreateMode = false.obs;

  // Selected goals
  var drinkWater = true.obs;
  var steps10k = true.obs;
  var noSugar = false.obs;
  var sleep8Hours = false.obs;

  // Exercises list
  var exercises = <String>[].obs;

  var isLoading = false.obs;
  final RxString nutritionPlanId = ''.obs;
  final RxString routineId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Parse arguments passed from Magaeclients screen
    final args = Get.arguments;
    if (args is Map) {
      clientId.value = args['id'] ?? '';
      clientName.value = args['name'] ?? 'Client';
      clientImage.value = args['imageUrl'] ?? 'assets/image/newprofile.png';
      isCreateMode.value = args['isCreate'] ?? false;
    } else {
      // Fallback
      clientId.value = 'default_client_id';
      clientName.value = 'Sarah Jenkins';
      clientImage.value = 'assets/image/Elena Rodriguez.png';
      isCreateMode.value = false;
    }

    // Initialize fields
    exercises.clear();
    drinkWater.value = false;
    steps10k.value = false;
    noSugar.value = false;
    sleep8Hours.value = false;
    caloriesController.clear();
    proteinController.clear();
    carbsController.clear();
    fatsController.clear();

    // Fetch existing routine if any
    fetchClientRoutine();
  }

  @override
  void onClose() {
    exerciseController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();
    super.onClose();
  }

  void _parseNotesGoals(dynamic goalsData) {
    if (goalsData == null) return;
    try {
      final decoded = goalsData is String ? jsonDecode(goalsData) : goalsData;
      if (decoded is Map) {
        drinkWater.value = decoded['drinkWater'] == true || decoded['Drink 3L Water'] == true;
        steps10k.value = decoded['steps10k'] == true || decoded['10k Steps'] == true;
        noSugar.value = decoded['noSugar'] == true || decoded['No Sugar Today'] == true;
        sleep8Hours.value = decoded['sleep8Hours'] == true || decoded['8 Hours Sleep'] == true;
        return;
      }
      if (decoded is List) {
        final list = decoded.map((e) => e?.toString().toLowerCase() ?? '').toList();
        drinkWater.value = drinkWater.value || list.any((g) => g.contains('water') || g.contains('drink'));
        steps10k.value = steps10k.value || list.any((g) => g.contains('step') || g.contains('10k'));
        noSugar.value = noSugar.value || list.any((g) => g.contains('sugar') || g.contains('no sugar'));
        sleep8Hours.value = sleep8Hours.value || list.any((g) => g.contains('sleep') || g.contains('8 hour'));
        return;
      }
    } catch (_) {}

    // Fallback: search raw string
    final lowerStr = goalsData.toString().toLowerCase();
    drinkWater.value = drinkWater.value || lowerStr.contains('water') || lowerStr.contains('drink');
    steps10k.value = steps10k.value || lowerStr.contains('step') || lowerStr.contains('10k');
    noSugar.value = noSugar.value || lowerStr.contains('sugar') || lowerStr.contains('no sugar');
    sleep8Hours.value = sleep8Hours.value || lowerStr.contains('sleep') || lowerStr.contains('8 hour');
  }

  Future<void> fetchClientRoutine() async {
    if (clientId.isEmpty || clientId.value == 'default_client_id') return;

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

      String? calories;
      String? protein;
      String? carbs;
      String? fats;
      List<String>? fetchedExercises;
      bool goalsLoaded = false;

      // Reset IDs
      nutritionPlanId.value = '';
      routineId.value = '';

      // Reset checkbox goals
      drinkWater.value = false;
      steps10k.value = false;
      noSugar.value = false;
      sleep8Hours.value = false;

      // 1. Try fetching from Dashboard API
      try {
        final dashboardUrl = Uri.parse("${ApiServices.dashboard}?client_id=${clientId.value}");
        debugPrint(">>> FETCHING DASHBOARD: $dashboardUrl");
        final dashboardResponse = await http.get(dashboardUrl, headers: headers);
        debugPrint("<<< DASHBOARD STATUS: ${dashboardResponse.statusCode}");
        
        if (dashboardResponse.statusCode == 200) {
          final data = jsonDecode(dashboardResponse.body);
          final clientDashboard = data['client_dashboard'];
          if (clientDashboard != null) {
            final todayRoutine = clientDashboard['today_routine'];
            if (todayRoutine != null) {
              debugPrint("Found today's routine in dashboard: $todayRoutine");
              routineId.value = todayRoutine['id']?.toString() ?? '';
              calories = (todayRoutine['goal_kcal'] ?? todayRoutine['calories'])?.toString();
              protein = (todayRoutine['goal_protein'] ?? todayRoutine['protein'])?.toString();
              carbs = (todayRoutine['goal_carbs'] ?? todayRoutine['carbs'])?.toString();
              fats = (todayRoutine['goal_fats'] ?? todayRoutine['fats'] ?? todayRoutine['fat'])?.toString();

              // Workout exercises
              final workoutData = todayRoutine['workout'] ?? todayRoutine['exercises'];
              if (workoutData != null) {
                if (workoutData is List) {
                  fetchedExercises = workoutData.map((e) => e.toString()).toList();
                } else {
                  final str = workoutData.toString();
                  try {
                    final decoded = jsonDecode(str);
                    if (decoded is List) {
                      fetchedExercises = decoded.map((e) => e.toString()).toList();
                    }
                  } catch (_) {
                    fetchedExercises = [str];
                  }
                }
              }

              // Daily goals
              final goalsData = todayRoutine['notes'] ?? todayRoutine['daily_goals'] ?? todayRoutine['goals'];
              if (goalsData != null) {
                _parseNotesGoals(goalsData);
                goalsLoaded = true;
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching dashboard: $e");
      }

      // 2. Try fetching from /coach/nutrition-plans
      try {
        final nutritionUrl = Uri.parse(ApiServices.coachNutritionPlans);
        debugPrint(">>> FETCHING NUTRITION PLANS: $nutritionUrl");
        final nutritionResponse = await http.get(nutritionUrl, headers: headers);
        debugPrint("<<< NUTRITION PLANS STATUS: ${nutritionResponse.statusCode}");

        if (nutritionResponse.statusCode == 200) {
          final List<dynamic> list = jsonDecode(nutritionResponse.body);
          final plan = list.firstWhere(
            (element) => element['client_id'] == clientId.value,
            orElse: () => null,
          );
          if (plan != null) {
            debugPrint("Found nutrition plan: $plan");
            nutritionPlanId.value = plan['id']?.toString() ?? '';
            calories ??= (plan['daily_calories'] ?? plan['calories'])?.toString();
            protein ??= (plan['protein'])?.toString();
            carbs ??= (plan['carbs'])?.toString();
            fats ??= (plan['fat'] ?? plan['fats'])?.toString();

            // Set drinkWater if water_goal is set and > 0
            final wGoal = double.tryParse((plan['water_goal'] ?? '0').toString()) ?? 0.0;
            if (wGoal > 0.0) {
              drinkWater.value = true;
            }

            final notesData = plan['notes'] ?? plan['daily_goals'] ?? plan['goals'];
            if (notesData != null && !goalsLoaded) {
              _parseNotesGoals(notesData);
              goalsLoaded = true;
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching nutrition plans: $e");
      }

      // 3. Try fetching from /routines
      try {
        final routinesUrl = Uri.parse("${ApiServices.routines}?client_id=${clientId.value}");
        debugPrint(">>> FETCHING ROUTINES: $routinesUrl");
        final routinesResponse = await http.get(routinesUrl, headers: headers);
        debugPrint("<<< ROUTINES STATUS: ${routinesResponse.statusCode}");

        if (routinesResponse.statusCode == 200) {
          final List<dynamic> list = jsonDecode(routinesResponse.body);
          final routine = list.firstWhere(
            (element) => element['client_id'] == clientId.value || element['user_id'] == clientId.value,
            orElse: () => null,
          );
          if (routine != null) {
            debugPrint("Found routine in fallback list: $routine");
            routineId.value = routine['id']?.toString() ?? '';
            calories ??= (routine['goal_kcal'] ?? routine['calories'])?.toString();
            protein ??= (routine['goal_protein'] ?? routine['protein'])?.toString();
            carbs ??= (routine['goal_carbs'] ?? routine['carbs'])?.toString();
            fats ??= (routine['goal_fats'] ?? routine['fats'] ?? routine['fat'])?.toString();

            if (fetchedExercises == null) {
              final workoutData = routine['workout'] ?? routine['exercises'];
              if (workoutData != null) {
                if (workoutData is List) {
                  fetchedExercises = workoutData.map((e) => e.toString()).toList();
                } else {
                  final str = workoutData.toString();
                  try {
                    final decoded = jsonDecode(str);
                    if (decoded is List) {
                      fetchedExercises = decoded.map((e) => e.toString()).toList();
                    }
                  } catch (_) {
                    fetchedExercises = [str];
                  }
                }
              }
            }

            if (!goalsLoaded) {
              final goalsData = routine['notes'] ?? routine['daily_goals'] ?? routine['goals'];
              if (goalsData != null) {
                _parseNotesGoals(goalsData);
                goalsLoaded = true;
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching routines: $e");
      }

      if (calories != null) caloriesController.text = calories;
      if (protein != null) proteinController.text = protein;
      if (carbs != null) carbsController.text = carbs;
      if (fats != null) fatsController.text = fats;

      if (fetchedExercises != null) {
        exercises.value = fetchedExercises;
      } else {
        exercises.clear();
      }

    } catch (e) {
      debugPrint("Error in fetchClientRoutine: $e");
    } finally {
      isLoading.value = false;

      // Default fallback if no exercises found and in edit mode
      if (exercises.isEmpty && !isCreateMode.value) {
        exercises.add("45min HIIT Session");
      }
    }
  }

  void _populateRoutineData(Map<String, dynamic> routine) {
    debugPrint("Populating routine data: $routine");

    // 1. Calories and macros
    caloriesController.text = (routine['goal_kcal'] ?? routine['calories'] ?? '').toString();
    proteinController.text = (routine['goal_protein'] ?? routine['protein'] ?? '').toString();
    carbsController.text = (routine['goal_carbs'] ?? routine['carbs'] ?? '').toString();
    fatsController.text = (routine['goal_fats'] ?? routine['fats'] ?? routine['fat'] ?? '').toString();

    // 2. Exercises/Workout
    final workoutData = routine['workout'] ?? routine['exercises'];
    if (workoutData != null) {
      if (workoutData is List) {
        exercises.value = workoutData.map((e) => e.toString()).toList();
      } else {
        final workoutStr = workoutData.toString();
        try {
          final decoded = jsonDecode(workoutStr);
          if (decoded is List) {
            exercises.value = decoded.map((e) => e.toString()).toList();
          } else {
            exercises.value = [workoutStr];
          }
        } catch (e) {
          if (workoutStr.contains('\n')) {
            exercises.value = workoutStr.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          } else if (workoutStr.contains(',')) {
            exercises.value = workoutStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          } else {
            exercises.value = [workoutStr];
          }
        }
      }
    } else {
      exercises.clear();
    }

    // 3. Daily Goals
    final goalsData = routine['daily_goals'] ?? routine['goals'] ?? routine['notes'];
    _parseNotesGoals(goalsData);
  }

  void addExercise() {
    final text = exerciseController.text.trim();
    if (text.isNotEmpty) {
      exercises.add(text);
      exerciseController.clear();
    }
  }

  void removeExercise(int index) {
    if (index < exercises.length) {
      exercises.removeAt(index);
    }
  }

  void toggleGoal(RxBool goal) {
    goal.value = !goal.value;
  }

  Future<void> submitRoutine() async {
    if (clientId.isEmpty || clientId.value == 'default_client_id') {
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
      if (token == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar("Error", "Authentication token not found.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // If there's text in exerciseController that wasn't added via the '+' button, add it automatically
      final unsavedExercise = exerciseController.text.trim();
      if (unsavedExercise.isNotEmpty) {
        exercises.add(unsavedExercise);
        exerciseController.clear();
      }

      // Construct goals list based on active checkboxes
      final List<String> dailyGoals = [];
      if (drinkWater.value) dailyGoals.add("Drink 3L Water");
      if (steps10k.value) dailyGoals.add("10k Steps");
      if (noSugar.value) dailyGoals.add("No Sugar Today");
      if (sleep8Hours.value) dailyGoals.add("8 Hours Sleep");

      final int calories = int.tryParse(caloriesController.text) ?? 2000;
      final int protein = int.tryParse(proteinController.text) ?? 150;
      final int carbs = int.tryParse(carbsController.text) ?? 200;
      final int fats = int.tryParse(fatsController.text) ?? 70;

      final body = jsonEncode({
        "date": DateTime.now().toUtc().toIso8601String().split('T')[0],
        "goal_kcal": calories,
        "goal_protein": protein,
        "goal_carbs": carbs,
        "goal_fats": fats,
        "workout": jsonEncode(exercises.toList()),
        "notes": jsonEncode(dailyGoals),

        // Legacy/compatibility fields
        "client_id": clientId.value,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fats": fats,
        "exercises": exercises.toList(),
        "daily_goals": dailyGoals,
      });

      final dateStr = DateTime.now().toUtc().toIso8601String().split('T')[0];

      // 1. Submit Routine
      final http.Response response;
      if (routineId.value.isNotEmpty) {
        final routinesPutUrl = Uri.parse("${ApiServices.routines}/${routineId.value}");
        final routinesPutBody = jsonEncode({
          "date": dateStr,
          "goal_kcal": calories,
          "goal_protein": protein,
          "goal_carbs": carbs,
          "goal_fats": fats,
          "workout": jsonEncode(exercises.toList()),
          "notes": jsonEncode(dailyGoals),
          "completion_status": false,
        });

        debugPrint(">>> UPDATING ROUTINE: PUT $routinesPutUrl");
        response = await http.put(
          routinesPutUrl,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: routinesPutBody,
        );
      } else {
        final routinesPostUrl = Uri.parse("${ApiServices.routines}?client_id=${clientId.value}");
        debugPrint(">>> CREATING ROUTINE: POST $routinesPostUrl");
        response = await http.post(
          routinesPostUrl,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );
      }

      // 2. Submit Nutrition Plan
      try {
        if (nutritionPlanId.value.isNotEmpty) {
          final nutritionPutUrl = Uri.parse("${ApiServices.coachNutritionPlans}/${nutritionPlanId.value}");
          final nutritionPutBody = jsonEncode({
            "client_id": clientId.value,
            "breakfast": "Planned",
            "lunch": "Planned",
            "dinner": "Planned",
            "snacks": "Planned",
            "daily_calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fat": fats,
            "water_goal": drinkWater.value ? 3.0 : 0.0,
            "notes": jsonEncode(dailyGoals),
            "date": dateStr,
          });

          debugPrint(">>> UPDATING NUTRITION PLAN: PUT $nutritionPutUrl");
          await http.put(
            nutritionPutUrl,
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: nutritionPutBody,
          );
        } else {
          final nutritionPostUrl = Uri.parse(ApiServices.coachNutritionPlans);
          final nutritionPostBody = jsonEncode({
            "client_id": clientId.value,
            "breakfast": "Planned",
            "lunch": "Planned",
            "dinner": "Planned",
            "snacks": "Planned",
            "daily_calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fat": fats,
            "water_goal": drinkWater.value ? 3.0 : 0.0,
            "notes": jsonEncode(dailyGoals),
            "date": dateStr,
          });

          debugPrint(">>> CREATING NUTRITION PLAN: POST $nutritionPostUrl");
          await http.post(
            nutritionPostUrl,
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: nutritionPostBody,
          );
        }
      } catch (e) {
        debugPrint("Error syncing nutrition plan: $e");
      }

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      debugPrint("==========================================================================");
      debugPrint("<<< API RESPONSE STATUS: ${response.statusCode}");
      debugPrint("<<< RESPONSE BODY:");
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body)));
      } catch (_) {
        debugPrint(response.body);
      }
      debugPrint("==========================================================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Routine saved and story generated!",
            backgroundColor: const Color(0xFF00B171), colorText: Colors.white);
        Get.offNamed(AppRoutes.adminhome);
      } else {
        Get.snackbar("Error", "Failed to save routine: ${response.statusCode}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      // Close the loading dialog in case of error
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