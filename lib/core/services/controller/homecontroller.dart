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

  var clientPages = <Map<String, dynamic>>[].obs;
  var isStoryLoading = false.obs;
  String authToken = "";

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(resp);
  }

  String normalizeImageUrl(String url) {
    if (url.startsWith('http')) {
      return url.replaceAll(':8000', ':8004');
    }
    String path = url;
    if (path.startsWith('/api/v1')) {
      path = path.replaceFirst('/api/v1', '');
    }
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return "http://10.10.28.89:8004$path";
  }

  Future<bool> fetchClientStorybook() async {
    isStoryLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        debugPrint("Auth token is null, cannot fetch storybook");
        return false;
      }
      authToken = token;

      String userId = prefs.getString('user_id') ?? '';
      if (userId.isEmpty) {
        final payload = parseJwt(token);
        userId = payload['sub'] ?? '';
      }
      debugPrint(">>> fetchClientStorybook using user_id: $userId");

      // 1. Fetch client dashboard on port 8000
      final dashboardUrl = Uri.parse("${ApiServices.baseUrl}/dashboard?client_id=$userId");
      final dashboardResponse = await http.get(
        dashboardUrl,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Get client dashboard status: ${dashboardResponse.statusCode}");
      if (dashboardResponse.statusCode == 200) {
        final Map<String, dynamic> dashData = jsonDecode(dashboardResponse.body);
        final clientDash = dashData['client_dashboard'];
        if (clientDash == null) {
          debugPrint("Client dashboard data is null");
          clientPages.clear();
          return false;
        }

        final todayStorybook = clientDash['today_storybook'];
        if (todayStorybook == null) {
          debugPrint("No today_storybook in dashboard");
          clientPages.clear();
          return false;
        }

        final String storybookId = todayStorybook['id'] ?? '';
        final String status = (todayStorybook['status'] ?? '').toString().toUpperCase();

        if (storybookId.isEmpty || status != 'COMPLETED') {
          debugPrint("Storybook is not ready or ID is empty (ID: $storybookId, Status: $status)");
          clientPages.clear();
          return false;
        }

        // 2. Fetch full details (pages) on port 8004
        final detailUrl = Uri.parse(ApiServices.storybookDetail(storybookId));
        final detailResponse = await http.get(
          detailUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        debugPrint("Get client storybook detail status: ${detailResponse.statusCode}");
        if (detailResponse.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(detailResponse.body);
          final List<dynamic> pages = data['pages'] ?? [];
          clientPages.value = pages.map((e) => Map<String, dynamic>.from(e)).toList();
          debugPrint("Successfully loaded ${clientPages.length} pages");
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error fetching client storybook: $e");
      return false;
    } finally {
      isStoryLoading.value = false;
    }
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
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> daysList = data['days'] ?? [];
        final fetched = daysList.map((x) => GoalDay.fromJson(x)).toList();
        
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
          tempGoals = List<GoalItem>.from(todayDay.items);
        }
      }

      // 2. Fetch today's routine to check if we have completed goals saved in 'notes'
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

      todayGoals.assignAll(tempGoals);
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
    pageController.dispose();
    noteController.dispose();
    super.onClose();
  }
}