

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/api_services.dart';
import 'schedule_controller.dart' show GoalItem, GoalDay, ScheduleController;
import 'storybook_controller.dart';
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
      id: json['id']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      instruction: json['instruction']?.toString() ?? '',
      completed: json['completed'] == true || json['completed'] == 1 || json['completed'].toString() == 'true',
      completedAt: json['completed_at']?.toString(),
    );
  }
}

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  var hasWorkout = false.obs;
  var workoutItems = <WorkoutItem>[].obs;
  var isWorkoutLoading = false.obs;

  PageController _pageController = PageController();
  PageController get pageController {
    try {
      void dummy() {}
      _pageController.addListener(dummy);
      _pageController.removeListener(dummy);
    } catch (_) {
      _pageController = PageController(initialPage: currentIndex.value);
    }
    return _pageController;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAssignedWorkoutPlan();
    fetchTodayGoals();
    fetchClientStorybook();
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
        _notifyScheduleController();
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
      _notifyScheduleController();
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

  StorybookController get storybookCtrl => Get.isRegistered<StorybookController>() 
      ? Get.find<StorybookController>() 
      : Get.put(StorybookController());

  RxList<Map<String, dynamic>> get clientPages => storybookCtrl.clientPages;
  RxBool get isStoryLoading => storybookCtrl.isStoryLoading;
  RxString get currentPdfUrl => storybookCtrl.currentPdfUrl;
  String get authToken => storybookCtrl.authToken;

  String normalizeImageUrl(String url) => storybookCtrl.normalizeImageUrl(url);

  Future<bool> fetchClientStorybook({String? storybookIdParam}) {
    return storybookCtrl.fetchClientStorybook(storybookIdParam: storybookIdParam);
  }

  Future<String?> fetchStorybookPdfUrl(String storybookId) {
    return storybookCtrl.fetchStorybookPdfUrl(storybookId);
  }

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < clientPages.length - 1) {
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
  TextEditingController _noteController = TextEditingController();
  TextEditingController get noteController {
    try {
      void dummy() {}
      _noteController.addListener(dummy);
      _noteController.removeListener(dummy);
    } catch (_) {
      _noteController = TextEditingController();
    }
    return _noteController;
  }

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

      // 1. Fetch weekly goals summary to get goals template
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

      List<GoalItem> tempGoals = [];

      if (response.statusCode == 200) {
        final dynamic parsedJson = jsonDecode(response.body);
        List<dynamic> daysList = [];
        if (parsedJson is Map) {
          daysList = parsedJson['days'] ?? parsedJson['items'] ?? parsedJson['goals'] ?? [];
        } else if (parsedJson is List) {
          daysList = parsedJson;
        }

        final fetched = daysList.map((x) {
          if (x is Map<String, dynamic>) return GoalDay.fromJson(x);
          if (x is Map) return GoalDay.fromJson(Map<String, dynamic>.from(x));
          return null;
        }).whereType<GoalDay>().toList();

        final today = DateTime.now().toLocal();
        var todayDay = fetched.firstWhereOrNull((d) {
          try {
            final date = DateTime.parse(d.date).toLocal();
            return date.year == today.year && date.month == today.month && date.day == today.day;
          } catch (_) {
            return false;
          }
        });

        // Fallback: Use first non-empty GoalDay if exact date match is not found
        todayDay ??= fetched.firstWhereOrNull((d) => d.items.isNotEmpty) ?? (fetched.isNotEmpty ? fetched.first : null);

        if (todayDay != null) {
          tempGoals = List<GoalItem>.from(todayDay.items);
        }
      }

      // 2. Fetch today's routine to check completed states or direct goals
      final routineUrl = Uri.parse(ApiServices.todayRoutine);
      final routineResponse = await http.get(
        routineUrl,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Today Routine Status in fetchTodayGoals: ${routineResponse.statusCode}");
      if (routineResponse.statusCode == 200) {
        final Map<String, dynamic> routineData = jsonDecode(routineResponse.body);

        // If tempGoals is empty, check if routineData contains goals list directly
        if (tempGoals.isEmpty) {
          final List<dynamic> routineGoals = routineData['goals'] ?? routineData['daily_goals'] ?? [];
          if (routineGoals.isNotEmpty) {
            tempGoals = routineGoals.map((x) {
              if (x is Map<String, dynamic>) return GoalItem.fromJson(x);
              if (x is Map) return GoalItem.fromJson(Map<String, dynamic>.from(x));
              return null;
            }).whereType<GoalItem>().toList();
          }
        }

        final String rawNotes = routineData['notes'] ?? '';
        final String notesStr = rawNotes.contains('|||') ? rawNotes.split('|||')[0] : rawNotes;
        if (notesStr.isNotEmpty && notesStr.startsWith('[')) {
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

            // Merge completed states
            if (completedMap.isNotEmpty) {
              tempGoals = tempGoals.map((goal) {
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
            }
          } catch (e) {
            debugPrint("Error parsing routine notes as JSON: $e");
          }
        }
      }

      // Fallback: If tempGoals is still empty, map from workoutItems
      if (tempGoals.isEmpty && workoutItems.isNotEmpty) {
        tempGoals = workoutItems.map((w) => GoalItem(
          id: w.id,
          position: w.position,
          instruction: w.instruction,
          completed: w.completed,
        )).toList();
      }

      todayGoals.assignAll(tempGoals);
      _notifyScheduleController();
    } catch (e) {
      debugPrint("Error fetching today goals: $e");
      todayGoals.clear();
    } finally {
      isGoalsLoading.value = false;
    }
  }

  void _notifyScheduleController() {
    if (Get.isRegistered<ScheduleController>()) {
      Get.find<ScheduleController>().syncWithHomeController();
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
      _notifyScheduleController();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      MacroController macroCtrl;
      if (Get.isRegistered<MacroController>()) {
        macroCtrl = Get.find<MacroController>();
      } else {
        macroCtrl = Get.put(MacroController());
      }
      if (macroCtrl.routineId.value.isEmpty) {
        await macroCtrl.fetchTodayRoutine();
      }

      String textNote = '';
      if (macroCtrl.routineId.value.isNotEmpty) {
        final todayUrl = Uri.parse(ApiServices.routineDetail(macroCtrl.routineId.value));
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
            textNote = rawNotes.split('|||')[1];
          } else if (!rawNotes.startsWith('[')) {
            textNote = rawNotes;
          }
        }
      }

      final dateStr = DateTime.now().toLocal().toIso8601String().split('T')[0];
      final goalsJson = jsonEncode(todayGoals.map((item) => {
        'id': item.id,
        'position': item.position,
        'instruction': item.instruction,
        'completed': item.completed,
      }).toList());

      final combinedNotes = goalsJson + '|||' + textNote;

      http.Response response;
      if (macroCtrl.routineId.value.isNotEmpty) {
        final url = Uri.parse(ApiServices.routineDetail(macroCtrl.routineId.value));
        debugPrint(">>> PATCH daily goals to existing routine: $url");
        response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'notes': combinedNotes,
          }),
        );
      } else {
        final url = Uri.parse(ApiServices.routines);
        debugPrint(">>> POST daily goals to create new routine: $url");
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'date': dateStr,
            'notes': combinedNotes,
            'completion_status': false,
          }),
        );
      }

      debugPrint("Update routine goals status: ${response.statusCode}");
      debugPrint("Update routine goals body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (macroCtrl.routineId.value.isEmpty && data['id'] != null) {
          macroCtrl.routineId.value = data['id'].toString();
        }
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
    super.onClose();
  }
}