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
    
    // Clear or initialize based on create/edit mode
    if (isCreateMode.value) {
      exercises.clear();
      drinkWater.value = false;
      steps10k.value = false;
      noSugar.value = false;
      sleep8Hours.value = false;
      caloriesController.clear();
      proteinController.clear();
      carbsController.clear();
      fatsController.clear();
    } else {
      // Add default values for edit mode if list is empty
      if (exercises.isEmpty) {
        exercises.add("45min HIIT Session");
      }
    }
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

      final body = jsonEncode({
        "client_id": clientId.value,
        "date": DateTime.now().toUtc().toIso8601String().split('T')[0],
        "calories": int.tryParse(caloriesController.text) ?? 2000,
        "protein": int.tryParse(proteinController.text) ?? 150,
        "carbs": int.tryParse(carbsController.text) ?? 200,
        "fats": int.tryParse(fatsController.text) ?? 70,
        "daily_goals": dailyGoals,
        "exercises": exercises.toList(),
      });

      final url = Uri.parse(ApiServices.routines);
      
      debugPrint("==========================================================================");
      debugPrint(">>> ROUTINE CREATION REQUEST FOR CLIENT: ${clientName.value} (ID: ${clientId.value})");
      debugPrint(">>> API ENDPOINT: POST $url");
      debugPrint(">>> REQUEST HEADERS: Authorization: Bearer $token");
      debugPrint(">>> REQUEST BODY (PAYLOAD):");
      debugPrint(const JsonEncoder.withIndent('  ').convert(jsonDecode(body)));
      debugPrint("==========================================================================");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      // Close the loading dialog
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