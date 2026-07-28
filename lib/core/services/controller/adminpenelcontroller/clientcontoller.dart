import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../api_services/api_services.dart';

class ClientController extends GetxController {

  RxString userName = "Alexander Mitchell".obs;
  RxString emailaddress = "alexander.m@dailey.ai".obs;
  RxString phonenumber = "+1 (555) 902-3482".obs;
  RxString coachbio = "Specializing in routine-building through narrative psychology. Helping over 50 clients find their daily flow since 2022.".obs;

  var searchText = "".obs;
  var drinkWater = true.obs;
  var steps10k = true.obs;
  var noSugar = false.obs;
  var sleep8Hours = false.obs;

  final TextEditingController searchController = TextEditingController();

  var clientList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var pendingRequestsCount = 0.obs;
  var generatingStorybookClientName = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchClients();
    fetchPendingRequests();
  }

  String authToken = "";

  Future<void> fetchClients() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;
      authToken = token;

      final url = Uri.parse(ApiServices.coachClients);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("ClientController: Fetch Clients Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        clientList.value = List<Map<String, dynamic>>.from(data);
        _fetchClientsProgress();
      }
    } catch (e) {
      debugPrint("Error fetching clients in ClientController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchClientsProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    final futures = clientList.map((client) async {
      final clientId = client['id'];
      if (clientId == null) return;

      try {
        final url = Uri.parse(ApiServices.coachClientWeeklySummary(clientId));
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> summary = jsonDecode(response.body);
          final progressPercent = (summary['weekly_progress_percentage'] ?? 0.0) is num 
              ? (summary['weekly_progress_percentage'] as num).toDouble() / 100.0
              : 0.0;
          final weekStart = summary['week_start'] ?? '';
          final weekEnd = summary['week_end'] ?? '';
          
          final index = clientList.indexWhere((c) => c['id'] == clientId);
          if (index != -1) {
            final updatedClient = Map<String, dynamic>.from(clientList[index]);
            updatedClient['progress'] = progressPercent;
            updatedClient['week_start'] = weekStart;
            updatedClient['week_end'] = weekEnd;
            clientList[index] = updatedClient;
          }
        }
      } catch (e) {
        debugPrint("Error fetching progress for client $clientId: $e");
      }
    }).toList();

    await Future.wait(futures);
    clientList.refresh();
  }

  void updateSearch(String value) {
    searchText.value = value;
    debugPrint("Searching for: $value");
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = "";
  }

  void toggleGoal(RxBool goal) {
    goal.value = !goal.value;
  }

  void onClientTap(int index) {
    var selectedClient = clientList[index];
    debugPrint("Navigating to: ${selectedClient['name']}");
  }

  void clearNotification(int index) {
    if (index < clientList.length) {
      clientList[index]['hasNotification'] = false;
      clientList.refresh();
    }
  }

  Future<void> fetchPendingRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.coachClientRequestsSent);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("ClientController: Fetch Sent Requests Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final pending = data.where((x) => x['status'] == 'PENDING').length;
        pendingRequestsCount.value = pending;
      }
    } catch (e) {
      debugPrint("Error fetching sent client requests: $e");
    }
  }

  Future<void> generateStorybookForClient(Map<String, dynamic> client) async {
    final String clientId = (client['client_id'] ?? client['client_uuid'] ?? client['user_id'] ?? client['id'] ?? '').toString().trim();
    final clientName = client['name'] ?? client['email'] ?? 'Client';
    
    debugPrint(">>> Generating storybook for clientName: $clientName, Client ID: $clientId");
    
    if (clientId.isEmpty || clientId == 'null') {
      debugPrint(">>> Error: Client ID is empty or null!");
      Get.snackbar(
        "Error",
        "Client ID is missing. Cannot generate storybook.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (generatingStorybookClientName.value.isNotEmpty) {
      Get.snackbar(
        "Busy",
        "Already generating a storybook for ${generatingStorybookClientName.value}. Please wait.",
        backgroundColor: Colors.amber,
        colorText: Colors.black87,
      );
      return;
    }

    generatingStorybookClientName.value = clientName;

    Get.snackbar(
      "Storybook Generation",
      "Starting storybook generation for $clientName. This will run in the background.",
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        generatingStorybookClientName.value = "";
        return;
      }

      const String contextJson = "string";

      final executeUrl = Uri.parse(ApiServices.executeStorybookGeneration);
      final request = http.MultipartRequest('POST', executeUrl);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['context_json'] = contextJson;
      request.fields['client_id'] = clientId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Execute Storybook Status: ${response.statusCode}");
      debugPrint("Execute Storybook Body: ${response.body}");
      
      if (response.statusCode == 202) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        final String? storybookId = resData['storybook_id'];
        
        if (storybookId != null) {
          debugPrint("Storybook creation started successfully! ID: $storybookId");
          
          _pollStorybookStatus(storybookId, clientName, token);
        } else {
          generatingStorybookClientName.value = "";
          Get.snackbar(
            "Error",
            "Storybook ID not returned by server.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        generatingStorybookClientName.value = "";
        Get.snackbar(
          "Error",
          "Failed to start storybook generation. Code ${response.statusCode}.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      generatingStorybookClientName.value = "";
      debugPrint("Error generating storybook for $clientName: $e");
      Get.snackbar(
        "Error",
        "Failed to generate storybook: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _pollStorybookStatus(String storybookId, String clientName, String token) {
    const pollInterval = Duration(seconds: 30);
    int attempts = 0;
    const maxAttempts = 30;

    Future.doWhile(() async {
      await Future.delayed(pollInterval);
      attempts++;
      
      try {
        final url = Uri.parse(ApiServices.storybookStatus(storybookId));
        final response = await http.get(
          url,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        debugPrint("Poll Storybook Status ($attempts): ${response.statusCode}");
        if (response.statusCode == 200) {
          final Map<String, dynamic> statusData = jsonDecode(response.body);
          final String status = statusData['status'] ?? '';
          
          debugPrint("Storybook $storybookId status: $status");

          if (status == 'COMPLETED') {
            generatingStorybookClientName.value = "";
            
            Get.defaultDialog(
              title: "Success",
              middleText: "Storybook generated successfully for $clientName!",
              textConfirm: "OK",
              confirmTextColor: Colors.white,
              buttonColor: const Color(0xFF00A37B),
              onConfirm: () {
                Get.back();
              },
            );
            return false;
          } else if (status == 'FAILED') {
            generatingStorybookClientName.value = "";
            Get.defaultDialog(
              title: "Failed",
              middleText: "Failed to generate storybook for $clientName. Please try again.",
              textConfirm: "OK",
              confirmTextColor: Colors.white,
              buttonColor: Colors.redAccent,
              onConfirm: () => Get.back(),
            );
            return false;
          }
        }
      } catch (e) {
        debugPrint("Error polling status: $e");
      }

      if (attempts >= maxAttempts) {
        generatingStorybookClientName.value = "";
        Get.snackbar(
          "Storybook Status",
          "Storybook generation for $clientName is taking longer than expected. Please check back later.",
          backgroundColor: Colors.amber,
          colorText: Colors.black87,
        );
        return false;
      }
      
      return true;
    });
  }

  Future<void> fetchAndOpenClientStorybook(Map<String, dynamic> client) async {
    final String clientId = (client['client_id'] ?? client['client_uuid'] ?? client['user_id'] ?? client['id'] ?? '').toString().trim();
    if (clientId.isEmpty || clientId == 'null') {
      Get.snackbar("Error", "Client ID is missing.");
      return;
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF00A37B)),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        Get.back();
        return;
      }

      // 1. List storybooks for this user
      final listUrl = Uri.parse(ApiServices.listStorybooks(clientId));
      final listResponse = await http.get(
        listUrl,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("List storybooks status: ${listResponse.statusCode}");
      if (listResponse.statusCode == 200) {
        final List<dynamic> storybooks = jsonDecode(listResponse.body);
        if (storybooks.isEmpty) {
          Get.back(); // close loading dialog
          Get.snackbar("No Storybook", "No storybook has been generated for this client yet.");
          return;
        }

        final latestStorybook = storybooks.first;
        final String storybookId = latestStorybook['id'];
        final String status = (latestStorybook['status'] ?? '').toString().toUpperCase();

        debugPrint("Latest Storybook ID: $storybookId, Status: $status");

        if (status == 'PENDING' || status == 'PROCESSING') {
          Get.back(); // close loading dialog
          Get.snackbar(
            "Generating",
            "Daily Storybook is currently generating for this client. Please wait.",
            backgroundColor: Colors.amber,
            colorText: Colors.black87,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        if (status == 'FAILED') {
          Get.back(); // close loading dialog
          Get.snackbar(
            "Failed",
            "Daily Storybook generation failed for this client. Tap 'CREATE STORY' to try again.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        // 2. Fetch full storybook details with pages
        final detailUrl = Uri.parse(ApiServices.storybookDetail(storybookId));
        final detailResponse = await http.get(
          detailUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        Get.back(); // close loading dialog
        debugPrint("Get storybook detail status: ${detailResponse.statusCode}");
        if (detailResponse.statusCode == 200) {
          final Map<String, dynamic> storybookData = jsonDecode(detailResponse.body);
          Get.toNamed(AppRoutes.viewstory, arguments: {
            'client': client,
            'storybook': storybookData,
          });
        } else {
          Get.snackbar("Error", "Failed to retrieve storybook pages.");
        }
      } else {
        Get.back();
        Get.snackbar("Error", "Failed to fetch client's storybooks.");
      }
    } catch (e) {
      Get.back();
      debugPrint("Error fetching client storybook: $e");
      Get.snackbar("Error", "An error occurred: $e");
    }
  }
}