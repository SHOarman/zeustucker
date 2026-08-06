import 'dart:convert';
import 'package:flutter/material.dart';
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
  final String? id;
  final String? mealType;
  final double? amount;
  final String? amountUnit;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final String? loggedAt;

  LoggedMeal({
    required this.name,
    required this.kcal,
    this.id,
    this.mealType,
    this.amount,
    this.amountUnit,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.loggedAt,
  });

  factory LoggedMeal.fromJson(Map<String, dynamic> json) {
    final double? parsedAmount = json['amount'] != null ? double.tryParse(json['amount'].toString()) : null;
    final double? parsedProtein = json['protein'] != null ? double.tryParse(json['protein'].toString()) : null;
    final double? parsedCarbs = json['carbs'] != null ? double.tryParse(json['carbs'].toString()) : null;
    final double? parsedFat = json['fat'] != null ? double.tryParse(json['fat'].toString()) : null;
    final double? parsedFiber = json['fiber'] != null ? double.tryParse(json['fiber'].toString()) : null;

    final int parsedKcal = (json['kcal'] != null
        ? num.tryParse(json['kcal'].toString())?.toInt()
        : num.tryParse(json['calories']?.toString() ?? '')?.toInt()) ?? 0;

    return LoggedMeal(
      name: json['food_name'] ?? json['name'] ?? json['food_item'] ?? '',
      kcal: parsedKcal,
      id: json['id']?.toString(),
      mealType: json['meal_type'] ?? json['macro_type'],
      amount: parsedAmount,
      amountUnit: json['amount_unit'],
      protein: parsedProtein,
      carbs: parsedCarbs,
      fat: parsedFat,
      fiber: parsedFiber,
      loggedAt: json['logged_at'] ?? json['last_logged_at'],
    );
  }
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
  final RxString routineId = ''.obs;

  // ── LoggedMealsSection State ───────────────────────
  final RxString selectedMealType = 'BREAKFAST'.obs;
  TextEditingController _foodNameCtrl = TextEditingController();
  TextEditingController get foodNameCtrl {
    try {
      void dummy() {}
      _foodNameCtrl.addListener(dummy);
      _foodNameCtrl.removeListener(dummy);
    } catch (_) {
      _foodNameCtrl = TextEditingController();
    }
    return _foodNameCtrl;
  }

  TextEditingController _kcalCtrl = TextEditingController();
  TextEditingController get kcalCtrl {
    try {
      void dummy() {}
      _kcalCtrl.addListener(dummy);
      _kcalCtrl.removeListener(dummy);
    } catch (_) {
      _kcalCtrl = TextEditingController();
    }
    return _kcalCtrl;
  }

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await fetchMacroTargets();
    await fetchTodayRoutine();
    await fetchLoggedMeals();
    fetchRecentFoods('protein');
    fetchRecentFoods('carbs');
    fetchRecentFoods('fats');
    fetchRecentFoods('misc');
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

      // Fetch user_id dynamically if it's not cached yet
      String userId = prefs.getString('user_id') ?? '';
      if (userId.isEmpty) {
        try {
          final profileUrl = Uri.parse(ApiServices.getProfile);
          final profileResponse = await http.get(profileUrl, headers: headers);
          if (profileResponse.statusCode == 200 || profileResponse.statusCode == 201) {
            final profileData = jsonDecode(profileResponse.body);
            final profileId = profileData['id'] ?? profileData['user_id'] ?? profileData['user']?['id'] ?? profileData['uid'];
            if (profileId != null) {
              userId = profileId.toString();
              await prefs.setString('user_id', userId);
              debugPrint("Fetched and saved user_id in fetchMacroTargets: $userId");
            }
          }
        } catch (e) {
          debugPrint("Error fetching profile to retrieve user_id in fetchMacroTargets: $e");
        }
      }

      try {
        final nutritionUrl = Uri.parse(ApiServices.coachNutritionPlans);
        debugPrint(
          ">>> FETCHING MACRO TARGETS FROM NUTRITION PLANS: $nutritionUrl",
        );
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
              final userPlans = sortedList
                  .where(
                    (p) =>
                        p['client_id']?.toString().toLowerCase() ==
                            userId.toLowerCase() ||
                        p['user_id']?.toString().toLowerCase() ==
                            userId.toLowerCase(),
                  )
                  .toList();
              if (userPlans.isNotEmpty) {
                plan = userPlans.last;
              }
            }

            plan ??= sortedList.last;
            debugPrint("Loaded macro targets from latest plan: $plan");

            caloriesGoal.value = _parseInt(
              plan['daily_calories'] ?? plan['calories'],
              0,
            );
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

      // Note: macro targets are loaded from fetchTodayRoutine and nutrition plans
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTodayRoutine() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.todayRoutine);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Today Routine Status: ${response.statusCode}");
      debugPrint("Get Today Routine Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        routineId.value = data['id'] ?? '';
        final String rawNotes = data['notes'] ?? '';
        if (rawNotes.contains('|||')) {
          dailyNotes.value = rawNotes.split('|||')[1];
        } else if (rawNotes.startsWith('[')) {
          dailyNotes.value = '';
        } else {
          dailyNotes.value = rawNotes;
        }
        completionStatus.value = data['completion_status'] ?? false;
      }
    } catch (e) {
      debugPrint("Error fetching today routine: $e");
    }
  }

  Future<void> fetchLoggedMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      if (routineId.value.isEmpty) {
        await fetchTodayRoutine();
      }
      if (routineId.value.isEmpty) {
        debugPrint("Skipping fetchLoggedMeals: routineId is empty");
        return;
      }
      final url = Uri.parse(ApiServices.routineMacroLogs(routineId.value));
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Today Macro Logs Status: ${response.statusCode}");
      debugPrint("Get Today Macro Logs Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        loggedMeals.value = list.map((x) => LoggedMeal.fromJson(x)).toList();

        double totalCalories = 0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFats = 0.0;
        double totalFiber = 0.0;

        for (var meal in loggedMeals) {
          totalCalories += meal.kcal;
          totalProtein += meal.protein ?? 0.0;
          totalCarbs += meal.carbs ?? 0.0;
          totalFats += meal.fat ?? 0.0;
          totalFiber += meal.fiber ?? 0.0;
        }

        caloriesConsumed.value = totalCalories.round();
        protein.value = totalProtein;
        carbs.value = totalCarbs;
        fats.value = totalFats;
        misc.value = totalFiber;
      }
    } catch (e) {
      debugPrint("Error fetching logged meals: $e");
    }
  }

  Future<void> saveRoutine() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        Get.snackbar("Error", "Auth token not found",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      final dateStr = DateTime.now().toLocal().toIso8601String().split('T')[0];

      // Fetch today's routine first to get the current checklist JSON
      String checklistJson = '[]';
      final todayUrl = Uri.parse(ApiServices.todayRoutine);
      final todayRes = await http.get(
        todayUrl,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (todayRes.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(todayRes.body);
        final String rawNotes = data['notes'] ?? '';
        if (rawNotes.contains('|||')) {
          checklistJson = rawNotes.split('|||')[0];
        } else if (rawNotes.startsWith('[')) {
          checklistJson = rawNotes;
        }
      }

      final combinedNotes = "$checklistJson|||${dailyNotes.value}";

      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        "date": dateStr,
        "goal_kcal": caloriesGoal.value,
        "goal_protein": proteinGoal.value,
        "goal_carbs": carbsGoal.value,
        "goal_fats": fatsGoal.value,
        "goal_fiber": miscGoal.value,
        "water_goal": 0.0,
        "workout": "[]",
        "notes": combinedNotes,
      };

      http.Response response;
      if (routineId.value.isNotEmpty) {
        final url = Uri.parse("${ApiServices.routines}/${routineId.value}");
        debugPrint(">>> CLIENT UPDATING ROUTINE: PUT $url");
        final updateBody = {
          "date": dateStr,
          "workout": "[]",
          "notes": combinedNotes,
          "completion_status": completionStatus.value,
        };
        response = await http.put(
          url,
          headers: headers,
          body: jsonEncode(updateBody),
        );
      } else {
        final url = Uri.parse(ApiServices.routines);
        debugPrint(">>> CLIENT CREATING ROUTINE: POST $url");
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      }

      debugPrint("Save Routine Status: ${response.statusCode}");
      debugPrint("Save Routine Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        routineId.value = data['id'] ?? '';
        Get.snackbar(
          'Success',
          'Routine saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00A781),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save routine: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error saving routine: $e");
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  final RxList<LoggedMeal> loggedMeals = <LoggedMeal>[].obs;

  final RxString dailyNotes = ''.obs;
  final RxBool completionStatus = false.obs;

  final RxList<LoggedMeal> recentProteinFoods = <LoggedMeal>[].obs;
  final RxList<LoggedMeal> recentCarbFoods = <LoggedMeal>[].obs;
  final RxList<LoggedMeal> recentFatFoods = <LoggedMeal>[].obs;
  final RxList<LoggedMeal> recentFiberFoods = <LoggedMeal>[].obs;

  Future<void> fetchRecentFoods(String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      String macroType = 'PROTEIN';
      final lowerCat = category.toLowerCase();
      if (lowerCat == 'carbs') {
        macroType = 'CARBS';
      } else if (lowerCat == 'fats' || lowerCat == 'fat') {
        macroType = 'FATS';
      } else if (lowerCat == 'misc' || lowerCat == 'fiber') {
        macroType = 'FIBER';
      }

      final url = Uri.parse('${ApiServices.macroRecent}?macro_type=$macroType&limit=8');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Recent Foods ($macroType) Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        final fetched = list.map((item) => LoggedMeal.fromJson(item)).toList();
        if (fetched.isNotEmpty) {
          if (macroType == 'PROTEIN') {
            recentProteinFoods.assignAll(fetched);
          } else if (macroType == 'CARBS') {
            recentCarbFoods.assignAll(fetched);
          } else if (macroType == 'FATS') {
            recentFatFoods.assignAll(fetched);
          } else if (macroType == 'FIBER') {
            recentFiberFoods.assignAll(fetched);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching recent foods: $e");
    }
  }


  Future<void> postMacroLog({
    required String mealType,
    required String foodName,
    required double amount,
    required String amountUnit,
    required int kcal,
    required double proteinVal,
    required double carbsVal,
    required double fatVal,
    required double fiberVal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.todayMacroLogs);
      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        "meal_type": mealType,
        "food_name": foodName,
        "amount": amount,
        "amount_unit": amountUnit,
        "kcal": kcal,
        "protein": proteinVal,
        "carbs": carbsVal,
        "fat": fatVal,
        "fiber": fiberVal,
        "logged_at": DateTime.now().toUtc().toIso8601String(),
      };

      debugPrint(">>> CREATING MACRO LOG: POST $url");
      debugPrint("Body: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint("Create Macro Log Status: ${response.statusCode}");
      debugPrint("Create Macro Log Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Successfully created macro log: ${response.body}");
        final data = jsonDecode(response.body);
        if (data['routine'] != null && data['routine']['id'] != null) {
          routineId.value = data['routine']['id'].toString();
        }
        fetchLoggedMeals(); // Refresh logged meals list
        fetchRecentFoods(mealType); // Refresh recent foods list
      } else {
        debugPrint("Failed to create macro log: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error creating macro log: $e");
    }
  }

  void addCustomMealLog({
    required String mealType,
    required String foodName,
    required double amount,
    required String amountUnit,
    required int kcal,
    required double proteinVal,
    required double carbsVal,
    required double fatVal,
    required double fiberVal,
  }) {
    protein.value += proteinVal;
    carbs.value += carbsVal;
    fats.value += fatVal;
    misc.value += fiberVal;
    caloriesConsumed.value += kcal;

    postMacroLog(
      mealType: mealType,
      foodName: foodName,
      amount: amount,
      amountUnit: amountUnit,
      kcal: kcal,
      proteinVal: proteinVal,
      carbsVal: carbsVal,
      fatVal: fatVal,
      fiberVal: fiberVal,
    );
  }

  Future<void> patchMacroLog({
    required String logId,
    required String mealType,
    required String foodName,
    required double amount,
    required String amountUnit,
    required int kcal,
    required double proteinVal,
    required double carbsVal,
    required double fatVal,
    required double fiberVal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse("${ApiServices.baseUrl}/routines/today/macro-logs/$logId");
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final body = {
        "meal_type": mealType,
        "food_name": foodName,
        "amount": amount,
        "amount_unit": amountUnit,
        "kcal": kcal,
        "protein": proteinVal,
        "carbs": carbsVal,
        "fat": fatVal,
        "fiber": fiberVal,
        "logged_at": DateTime.now().toUtc().toIso8601String(),
      };

      debugPrint(">>> UPDATING MACRO LOG: PATCH $url");
      debugPrint("Body: ${jsonEncode(body)}");

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint("Update Macro Log Status: ${response.statusCode}");
      debugPrint("Update Macro Log Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Successfully updated macro log: ${response.body}");
        fetchLoggedMeals(); // Refresh logged meals list
      } else {
        debugPrint("Failed to update macro log: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error updating macro log: $e");
    }
  }

  void addProtein(double grams, {String? foodName, String? logId}) {
    if (logId != null) {
      final existing = loggedMeals.firstWhereOrNull((m) => m.id == logId);
      if (existing != null) {
        final newProtein = grams;
        final newKcal = (newProtein * 4 + (existing.carbs ?? 0.0) * 4 + (existing.fat ?? 0.0) * 9 + (existing.fiber ?? 0.0) * 2).round();
        patchMacroLog(
          logId: logId,
          mealType: existing.mealType ?? "BREAKFAST",
          foodName: existing.name,
          amount: grams,
          amountUnit: existing.amountUnit ?? "g",
          kcal: newKcal,
          proteinVal: newProtein,
          carbsVal: existing.carbs ?? 0.0,
          fatVal: existing.fat ?? 0.0,
          fiberVal: existing.fiber ?? 0.0,
        );
        return;
      }
    }

    protein.value += grams;
    caloriesConsumed.value += (grams * 4).round();
    postMacroLog(
      mealType: "BREAKFAST",
      foodName: foodName ?? "Protein",
      amount: grams,
      amountUnit: "g",
      kcal: (grams * 4).round(),
      proteinVal: grams,
      carbsVal: 0.0,
      fatVal: 0.0,
      fiberVal: 0.0,
    );
  }

  void addCarbs(double grams, {String? foodName, String? logId}) {
    if (logId != null) {
      final existing = loggedMeals.firstWhereOrNull((m) => m.id == logId);
      if (existing != null) {
        final newCarbs = grams;
        final newKcal = ((existing.protein ?? 0.0) * 4 + newCarbs * 4 + (existing.fat ?? 0.0) * 9 + (existing.fiber ?? 0.0) * 2).round();
        patchMacroLog(
          logId: logId,
          mealType: existing.mealType ?? "BREAKFAST",
          foodName: existing.name,
          amount: grams,
          amountUnit: existing.amountUnit ?? "g",
          kcal: newKcal,
          proteinVal: existing.protein ?? 0.0,
          carbsVal: newCarbs,
          fatVal: existing.fat ?? 0.0,
          fiberVal: existing.fiber ?? 0.0,
        );
        return;
      }
    }

    carbs.value += grams;
    caloriesConsumed.value += (grams * 4).round();
    postMacroLog(
      mealType: "BREAKFAST",
      foodName: foodName ?? "Carbs",
      amount: grams,
      amountUnit: "g",
      kcal: (grams * 4).round(),
      proteinVal: 0.0,
      carbsVal: grams,
      fatVal: 0.0,
      fiberVal: 0.0,
    );
  }

  void addFats(double grams, {String? foodName, String? logId}) {
    if (logId != null) {
      final existing = loggedMeals.firstWhereOrNull((m) => m.id == logId);
      if (existing != null) {
        final newFat = grams;
        final newKcal = ((existing.protein ?? 0.0) * 4 + (existing.carbs ?? 0.0) * 4 + newFat * 9 + (existing.fiber ?? 0.0) * 2).round();
        patchMacroLog(
          logId: logId,
          mealType: existing.mealType ?? "BREAKFAST",
          foodName: existing.name,
          amount: grams,
          amountUnit: existing.amountUnit ?? "g",
          kcal: newKcal,
          proteinVal: existing.protein ?? 0.0,
          carbsVal: existing.carbs ?? 0.0,
          fatVal: newFat,
          fiberVal: existing.fiber ?? 0.0,
        );
        return;
      }
    }

    fats.value += grams;
    caloriesConsumed.value += (grams * 9).round();
    postMacroLog(
      mealType: "BREAKFAST",
      foodName: foodName ?? "Fats",
      amount: grams,
      amountUnit: "g",
      kcal: (grams * 9).round(),
      proteinVal: 0.0,
      carbsVal: 0.0,
      fatVal: grams,
      fiberVal: 0.0,
    );
  }

  void addMisc(double grams, {String? foodName, String? logId}) {
    if (logId != null) {
      final existing = loggedMeals.firstWhereOrNull((m) => m.id == logId);
      if (existing != null) {
        final newFiber = grams;
        final newKcal = ((existing.protein ?? 0.0) * 4 + (existing.carbs ?? 0.0) * 4 + (existing.fat ?? 0.0) * 9 + newFiber * 2).round();
        patchMacroLog(
          logId: logId,
          mealType: existing.mealType ?? "BREAKFAST",
          foodName: existing.name,
          amount: grams,
          amountUnit: existing.amountUnit ?? "g",
          kcal: newKcal,
          proteinVal: existing.protein ?? 0.0,
          carbsVal: existing.carbs ?? 0.0,
          fatVal: existing.fat ?? 0.0,
          fiberVal: newFiber,
        );
        return;
      }
    }

    misc.value += grams;
    caloriesConsumed.value += (grams * 2).round();
    postMacroLog(
      mealType: "BREAKFAST",
      foodName: foodName ?? "Fiber",
      amount: grams,
      amountUnit: "g",
      kcal: (grams * 2).round(),
      proteinVal: 0.0,
      carbsVal: 0.0,
      fatVal: 0.0,
      fiberVal: grams,
    );
  }

  String get calMultiplier {
    return '${caloriesConsumed.value}';
  }
}
