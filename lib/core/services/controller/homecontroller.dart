import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/api_services.dart';
import 'schedule_controller.dart' show GoalItem, GoalDay;
import 'macro_controller.dart';

class WorkoutItem {
  final String id;
  final int position;
  final String instruction;
  bool completed;
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
      id: json['id'] ?? '',
      position: json['position'] ?? 0,
      instruction: json['instruction'] ?? '',
      completed: json['completed'] ?? false,
      completedAt: json['completed_at'],
    );
  }
}

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  var hasWorkout = false.obs;
  var workoutItems = <WorkoutItem>[].obs;
  var isWorkoutLoading = false.obs;

  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    fetchAssignedWorkoutPlan();
    fetchTodayGoals();
  }

  Future<void> fetchAssignedWorkoutPlan() async {
    isWorkoutLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        debugPrint("Auth token is null, cannot fetch assigned workout plan");
        return;
      }

      final url = Uri.parse(ApiServices.assignedWorkoutPlan);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get Assigned Workout Status: ${response.statusCode}");
      debugPrint("Get Assigned Workout Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data['items'] ?? [];
        workoutItems.value = itemsJson.map((x) => WorkoutItem.fromJson(x)).toList();
        hasWorkout.value = workoutItems.isNotEmpty;
      } else {
        workoutItems.clear();
        hasWorkout.value = false;
      }
    } catch (e) {
      debugPrint("Error fetching assigned workout plan: $e");
      workoutItems.clear();
      hasWorkout.value = false;
    } finally {
      isWorkoutLoading.value = false;
    }
  }

  Future<void> toggleWorkoutItemCompletion(String workoutItemId, bool completed) async {
    // Optimistic update
    final index = workoutItems.indexWhere((item) => item.id == workoutItemId);
    if (index != -1) {
      workoutItems[index].completed = completed;
      workoutItems.refresh();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.patchAssignedWorkoutItem(workoutItemId));
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'completed': completed,
        }),
      );

      debugPrint("PATCH workout item status: ${response.statusCode}");
      debugPrint("PATCH workout item body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (index != -1) {
          workoutItems[index] = WorkoutItem.fromJson(data);
          workoutItems.refresh();
        }
        Get.snackbar(
          "Success",
          completed ? "Workout marked as completed!" : "Workout marked as incomplete!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1CBBA7),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        // Revert optimistic update
        if (index != -1) {
          workoutItems[index].completed = !completed;
          workoutItems.refresh();
        }
        Get.snackbar(
          "Error",
          "Failed to update workout status",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Revert optimistic update
      if (index != -1) {
        workoutItems[index].completed = !completed;
        workoutItems.refresh();
      }
      debugPrint("Error updating workout item: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  final List<String> storyPages = [
    "assets/image/s1.png",
    "assets/image/s2.png",
    "assets/image/s3.png",
  ];

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < storyPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
 //====================working================workout

  void toggleWorkout() {
    hasWorkout.value = !hasWorkout.value;
  }

//====================add Routing-====================================
  final noteController = TextEditingController();

  void postNote() {
    String note = noteController.text.trim();
    if (note.isNotEmpty) {
      debugPrint("Note Posted: $note");
      noteController.clear();
      Get.snackbar("Success", "Note added to your routine!",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Error", "Please enter a note first",
          snackPosition: SnackPosition.BOTTOM);
    }
  }



  final RxList<GoalItem> todayGoals = <GoalItem>[].obs;
  final RxBool isGoalsLoading = false.obs;

  Future<void> fetchTodayGoals() async {
    isGoalsLoading.value = true;
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

      debugPrint("Get Today Goals Status: ${response.statusCode}");
      debugPrint("Get Today Goals Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> daysList = data['days'] ?? [];
        final fetched = daysList.map((x) => GoalDay.fromJson(x)).toList();
        
        final todayStr = DateTime.now().toLocal().toIso8601String().split('T')[0];
        final todayDay = fetched.firstWhereOrNull((d) => d.date == todayStr);
        if (todayDay != null) {
          todayGoals.assignAll(todayDay.items);
        } else {
          todayGoals.clear();
        }
      } else {
        todayGoals.clear();
      }
    } catch (e) {
      debugPrint("Error fetching today goals: $e");
      todayGoals.clear();
    } finally {
      isGoalsLoading.value = false;
    }
  }

  Future<void> toggleGoalItemCompletion(String goalItemId, bool completed) async {
    final index = todayGoals.indexWhere((item) => item.id == goalItemId);
    if (index != -1) {
      final oldItem = todayGoals[index];
      todayGoals[index] = GoalItem(
        id: oldItem.id,
        position: oldItem.position,
        instruction: oldItem.instruction,
        completed: completed,
      );
      todayGoals.refresh();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final macroCtrl = Get.find<MacroController>();
      final rId = macroCtrl.routineId.value;
      if (rId.isEmpty) {
        debugPrint("Routine ID is empty, cannot update daily goals.");
        return;
      }

      final url = Uri.parse(ApiServices.routineDetail(rId));
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'notes': jsonEncode(todayGoals.map((item) => {
            'id': item.id,
            'position': item.position,
            'instruction': item.instruction,
            'completed': item.completed,
          }).toList()),
        }),
      );

      debugPrint("PATCH routine goals status: ${response.statusCode}");
      debugPrint("PATCH routine goals body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          completed ? "Goal marked as completed!" : "Goal marked as incomplete!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1CBBA7),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        if (index != -1) {
          final oldItem = todayGoals[index];
          todayGoals[index] = GoalItem(
            id: oldItem.id,
            position: oldItem.position,
            instruction: oldItem.instruction,
            completed: !completed,
          );
          todayGoals.refresh();
        }
        Get.snackbar(
          "Error",
          "Failed to update goal status",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (index != -1) {
        final oldItem = todayGoals[index];
        todayGoals[index] = GoalItem(
          id: oldItem.id,
          position: oldItem.position,
          instruction: oldItem.instruction,
          completed: !completed,
        );
        todayGoals.refresh();
      }
      debugPrint("Error updating goal item: $e");
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    noteController.dispose();
    super.onClose();
  }
}